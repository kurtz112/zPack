object zViewerExcelEditor: TzViewerExcelEditor
  Left = 0
  Top = 0
  Caption = 'Foglio di calcolo'
  ClientHeight = 679
  ClientWidth = 1485
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 15
  object dxRibbonStatusBar: TdxRibbonStatusBar
    Left = 0
    Top = 656
    Width = 1485
    Height = 23
    Color = clBtnFace
    Panels = <>
    Ribbon = dxRibbon
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object dxRibbon: TdxRibbon
    Left = 0
    Top = 0
    Width = 1485
    Height = 132
    ApplicationButton.Visible = False
    BarManager = dxBarManager
    Style = rs2019
    ColorSchemeAccent = rcsaGreen
    ColorSchemeName = 'Colorful'
    QuickAccessToolbar.Visible = False
    Contexts = <>
    TabOrder = 1
    TabStop = False
    object dxRibbonTabFile: TdxRibbonTab
      Active = True
      Caption = 'File'
      Groups = <
        item
          Caption = 'File'
          ToolbarName = 'dxBarCommon'
        end
        item
          Caption = 'Mode'
          ToolbarName = 'dxBarMode'
        end
        item
          Caption = 'Template Sections'
          ToolbarName = 'dxBarTemplateSections'
        end
        item
          Caption = 'Sort & Group'
          ToolbarName = 'dxBarSortGroup'
        end
        item
          Caption = 'Filter'
          ToolbarName = 'dxBarFilter'
        end
        item
          Caption = 'Design'
          ToolbarName = 'dxBarDesign'
        end
        item
          Caption = 'Chiudi'
          ToolbarName = 'dxBarManagerBar1'
        end>
      Index = 0
    end
    object dxRibbonTabHome: TdxRibbonTab
      Caption = 'Home'
      Groups = <
        item
          Caption = 'Appunti'
          ToolbarName = 'dxBarClipboard'
        end
        item
          Caption = 'Carattere'
          ToolbarName = 'dxBarFont'
        end
        item
          Caption = 'Allineamento'
          ToolbarName = 'dxBarAlignment'
        end
        item
          Caption = 'Celle'
          ToolbarName = 'dxBarCells'
        end
        item
          Caption = 'Modifica'
          ToolbarName = 'dxBarEditing'
        end
        item
          Caption = 'Formattazione condizionale'
          ToolbarName = 'dxBarConditionalFormatting'
        end>
      Index = 1
    end
    object dxRibbonTabInsert: TdxRibbonTab
      Caption = 'Inserisci'
      Groups = <
        item
          Caption = 'Illustrazioni'
          ToolbarName = 'dxBarIllustrations'
        end
        item
          Caption = 'Links'
          ToolbarName = 'dxBarLinks'
        end>
      Index = 2
    end
    object dxRibbonTabPageLayout: TdxRibbonTab
      Caption = 'Layout di pagina'
      Groups = <
        item
          Caption = 'Impostazioni pagina'
          ToolbarName = 'dxBarPageSetup'
        end>
      Index = 3
    end
    object dxRibbonTabFormulas: TdxRibbonTab
      Caption = 'Formule'
      Groups = <
        item
          Caption = 'Libreria di funzioni'
          ToolbarName = 'dxBarFunctionLibrary'
        end
        item
          Caption = 'Nomi definiti'
          ToolbarName = 'dxBarDefinedNames'
        end
        item
          Caption = 'Verifica formule'
          ToolbarName = 'dxBarManagerBar2'
        end>
      Index = 4
    end
    object dxRibbonTabData: TdxRibbonTab
      Caption = 'Dati'
      Groups = <
        item
          Caption = 'Ordina e filtra'
          ToolbarName = 'dxBarSortFilter'
        end
        item
          Caption = 'Raggruppamento'
          ToolbarName = 'dxBarGrouping'
        end>
      Index = 5
    end
    object dxRibbonTabReview: TdxRibbonTab
      Caption = 'Revisione'
      Groups = <
        item
          Caption = 'Commenti'
          ToolbarName = 'dxBarComments'
        end
        item
          Caption = 'Modifiche'
          ToolbarName = 'dxBarChanges'
        end>
      Index = 6
    end
    object dxRibbonTabView: TdxRibbonTab
      Caption = 'Visualizza'
      Groups = <
        item
          Caption = 'Zoom'
          ToolbarName = 'dxBarZoom'
        end
        item
          Caption = 'Blocca riquadri'
          ToolbarName = 'dxBarFreezePanes'
        end>
      Index = 7
    end
  end
  object dxLayoutControl: TdxLayoutControl
    Left = 0
    Top = 132
    Width = 1485
    Height = 524
    Align = alClient
    TabOrder = 2
    AutoSize = True
    object dxSpreadSheetReportDesigner: TdxSpreadSheetReportDesigner
      Left = 12
      Top = 42
      Width = 1233
      Height = 470
      DataBinding.DataGroups = <
        item
        end>
      DataBinding.DataSource = DataSource
      DataBinding.SortedFields = <>
      OnPopulateField = dxSpreadSheetReportDesignerPopulateField
      Data = {
        9C02000044585353763242461000000042465320000000000000000001000101
        010100000100000001004246532000000000424653200100000001000000200B
        00000007000000430061006C0069006200720069000000000000002000000020
        0000000020000000000020000000000020000000000020000007000000470045
        004E004500520041004C00000000000002000000000000000001424653200100
        0000424653201D00000054006400780053007000720065006100640053006800
        6500650074005200650070006F00720074005400610062006C00650056006900
        650077000600000053006800650065007400310001FFFFFFFFFFFFFFFF640000
        0002000000020000000200000055000000140000000200000002000000000200
        0000020000000000000100000000000101000042465320550000000000000042
        4653200000000042465320140000000000000042465320000000000000000000
        0000000100000000000000000000000000000000000000424653200000000002
        0200000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000064000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000200020200020000000000000000000000
        0000000000000200000000000000000000000000000000000000000000000000
        0000000000000000000002020000000000000000424653200000000000000000
        040000004C007500630061000000000000000000040000004C00750063006100
        0000000000000000285471D078E7E54037D478D078E7E5400000000000000000}
    end
    object groupCampi: TcxGroupBox
      Left = 1261
      Top = 307
      Style.TransparentBorder = False
      TabOrder = 3
      Height = 205
      Width = 212
    end
    object cxRTTIInspector: TcxRTTIInspector
      Left = 1261
      Top = 42
      Width = 212
      Height = 249
      InspectedObject = dxSpreadSheetReportDesigner
      LookAndFeel.SkinName = 'UserSkin'
      OptionsView.RowHeaderWidth = 104
      TabOrder = 2
      OnDblClick = cxRTTIInspectorDblClick
      OnEditValueChanged = cxRTTIInspectorEditValueChanged
      Version = 1
    end
    object dxSpreadSheetFormulaBar: TdxSpreadSheetFormulaBar
      Left = 12
      Top = 12
      Width = 1461
      Height = 23
      SpreadSheet = dxSpreadSheetReportDesigner
      TabOrder = 0
    end
    object dxLayoutControlGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      ItemIndex = 1
      ShowBorder = False
      Index = -1
    end
    object dxLayoutItemDesigner: TdxLayoutItem
      Parent = dxLayoutGroupDesigner
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'dxSpreadSheetReportDesigner'
      CaptionOptions.Visible = False
      Control = dxSpreadSheetReportDesigner
      ControlOptions.OriginalHeight = 589
      ControlOptions.OriginalWidth = 1077
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItemCampi: TdxLayoutItem
      Parent = dxLayoutGroupDetail
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Campi DataSet'
      CaptionOptions.Visible = False
      Control = groupCampi
      ControlOptions.AutoColor = True
      ControlOptions.OriginalHeight = 164
      ControlOptions.OriginalWidth = 185
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutSplitterItem: TdxLayoutSplitterItem
      Parent = dxLayoutGroupDesigner
      AlignVert = avClient
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      CaptionOptions.Text = 'Splitter'
      Index = 1
    end
    object dxLayoutGroupDesigner: TdxLayoutGroup
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Designer'
      ItemIndex = 2
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 1
    end
    object dxLayoutItemInspector: TdxLayoutItem
      Parent = dxLayoutGroupDetail
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Inspector'
      CaptionOptions.Visible = False
      Control = cxRTTIInspector
      ControlOptions.OriginalHeight = 200
      ControlOptions.OriginalWidth = 150
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutGroupDetail: TdxLayoutGroup
      Parent = dxLayoutGroupDesigner
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'New Group'
      ItemIndex = 2
      ShowBorder = False
      Index = 2
    end
    object dxLayoutSplitterItemFields: TdxLayoutSplitterItem
      Parent = dxLayoutGroupDetail
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      CaptionOptions.Text = 'Divisore'
      Index = 1
    end
    object dxLayoutItemFormulaBar: TdxLayoutItem
      Parent = dxLayoutControlGroup_Root
      AlignHorz = ahClient
      CaptionOptions.Text = 'dxSpreadSheetFormulaBar1'
      CaptionOptions.Visible = False
      Control = dxSpreadSheetFormulaBar
      ControlOptions.OriginalHeight = 23
      ControlOptions.OriginalWidth = 300
      ControlOptions.ShowBorder = False
      Index = 0
    end
  end
  object dxComponentPrinter: TdxComponentPrinter
    CurrentLink = dxComponentPrinterLink
    Version = 0
    Left = 256
    Top = 424
    PixelsPerInch = 96
    object dxComponentPrinterLink: TdxSpreadSheetReportLnk
      Component = dxSpreadSheetReportDesigner
      PageNumberFormat = pnfNumeral
      PrinterPage.DMPaper = 9
      PrinterPage.Footer = 6350
      PrinterPage.GrayShading = True
      PrinterPage.Header = 6350
      PrinterPage.Margins.Bottom = 12700
      PrinterPage.Margins.Left = 12700
      PrinterPage.Margins.Right = 12700
      PrinterPage.Margins.Top = 12700
      PrinterPage.PageSize.X = 210000
      PrinterPage.PageSize.Y = 297000
      PrinterPage._dxMeasurementUnits_ = 0
      PrinterPage._dxLastMU_ = 2
      ReportDocument.Caption = 'Report'
      TimeFormat = 0
      OptionsView = []
      PixelsPerInch = 96
      BuiltInReportLink = True
    end
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default'
      'File | Common'
      'File | Print'
      'Home | Clipboard'
      'Home | Font'
      'Home | Alignment'
      'Home | Cells'
      'Home | Editing'
      'Insert | Illustrations'
      'Insert | Links'
      'Page Layout | Page Setup'
      'Formulas | Function Library'
      'Formulas | Defined Names'
      'Data | Sort Filter'
      'Data | Grouping'
      'Review | Comments'
      'Review | Changes'
      'View | Zoom'
      'View | Freeze Panes'
      'Home | Conditional Formatting'
      'Report | Mode'
      'Report | Template Sections'
      'Report | Sort & Group'
      'Report | Filter'
      'Report | Design')
    Categories.ItemsVisibles = (
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2)
    Categories.Visibles = (
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True)
    ImageOptions.Images = dx.Immagini
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 256
    Top = 256
    PixelsPerInch = 96
    object dxBarCommon: TdxBar
      Caption = 'File'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000003D744558745469746C65004E65773B506167653B426172733B526962
        626F6E3B5374616E646172643B4974656D3B426C616E6B3B44656661756C743B
        456D7074793B130452ED0000016349444154785E6D51314E04310C1CEF1E0289
        B7D0D3C035347C006A2A3AC413A8A9111D15E20B743420D1DE6310E2F612DBC8
        B11372DC269BC4BBF1CC8EC70B5505118D8F2FABB7611C970A850D3BEC2EC2B6
        D9A79CA68FDBABE33355DD2CE06300D1F2FAF2C8E21D10407EC6FEF0BC3A0130
        1AB01210B3946093045A49D4379BFE10F6F706E45C72879E002CCE2E1DDAF1F1
        1ACBE859B8C27A05A9D61DA0DE030A02BBA3AA80FE1178AA4803951C356564D0
        CEC4CCBB04393114A180C84F4F6B31A99794D2AE026CC2448181B7DB286122DB
        1245E61905927301899802448CE8405352569E333145FB44B5815BDD2EA3DDE7
        AC331E30438BC46656AB5B10C362CB9933910B525D41DF3E9BBD1A19C0336D44
        628163156182CF4AA643FB01F30C8164F7E0F060E11D28C904F5DF7B77C44B10
        F13A7B82BC9EBEDF6FEE5E4F15CD441069B09707146AA6F5D7A775BE27989EEE
        2FCE01EC0118AA2FFDD9C51AE01F03FE022E9833255C6BD8490000000049454E
        44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonNew'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton4'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSaveAs'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton5'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonPrintPreview'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton3'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarClipboard: TdxBar
      Caption = 'Clipboard'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000021744558745469746C650050617374653B426172733B526962626F6E
        3B5374616E646172643B259B079D000001EF49444154785E75523B681451143D
        6F77418D86A056DB0AC26A61A512035A8C168A59B0102C5C2C836817145448E3
        070C2954B00AC4C23695209A66D32A29B7B6B050D2C8261A7666DFE7DEEBDC97
        9D0167DD03877BE631E7BC3B87312282024FDF7CD6D18541A2C7C20266C26090
        6D3A3BBC7C78F32E142FBFA428502BC4B7F54EF712DE0A33270B9D8B98BDD0C2
        F9B916CECD9E427FA79F246655EEDC6F775141A3106A6C5D5FC4A7B51E9E3CDB
        867316DE79386B71FCE01E4ECE77B0D3FB904C0E20C1D16333B83DF713DBDF7F
        00C6A05ECBD9A8E1C8D40198BD3EB2D46262000546A30EB4CE9C40B33983DD5F
        BB00044669540A606A58FE9A1D5A8E071000AE2CB1F7EEA69CBEB188D0DF8277
        0E2B1B6721C239B5C89C3183A316D267C6ABA5F654B941F0040916E22D82B5DA
        099E3FB882FFC113E3E18B8F2AEB6500B900D0101C2CC8E72482E277EA2190A8
        45460440C46A336580B701EC33B0B3FB648682D55C1A254E551CE8DF80603DD8
        65FA0991C46A8D09718A1453A20E24E31B884F630FE41C288C0A4434A82E8354
        108F6DE0202103FB7C9203094723AB510C507EC2E40E36BAABEFAFEA4DE93080
        9AED7D33974645D1C578C0FCEBAD6B8536C64C2F3CE23F1C572F8AAC0471A583
        0A586FB8F7783DBEC8C2A31EB8BA519814305C5BB9353DFAD50D14E393000CFE
        023DB570481AE91B650000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPaste'
        end
        item
          Position = ipBeginsNewColumn
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonCut'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonCopy'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarFont: TdxBar
      Caption = 'Font'
      CaptionButtons = <>
      DockedLeft = 131
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000016744558745469746C6500466F6E74436F6C6F723B436F6C6F723B31
        8354C20000012D49444154785EA593214B04511485EFEC330A6211115C77ABE0
        3F3088C9A4980441108401C560B4EB1F1036592C229A2C068B36F13798ACE21A
        4D1BEEF163B9032FF8A6CC0CDF9C7378DCCBBB17A692645D9E9E757C66F2B0B4
        736112860F2F6A4F92D6618130414DF0F37CF97F83BC58521FBF454CE8AECC1F
        A2416984280E3047E89BE406A7F238F37283BC38A1359CC3AF33864C6B789379
        79078AD931DBF84F78873B93D7E8319C40FB0D0C44015C03D94731D601CC49AD
        37704443B13C39986EF0668E93CF8A26B851EB0850E3AE70677237D4C87BE8FD
        748CF6064A263F4437205FEAA3E45FF855D8A4E0B5B003FF90B408B740F6292E
        DF277F83C14B5ED3F15F8811AAAA4A8614E8E53E47D2B8D9C17C1CA4D0288A1C
        9AFBD071B38365E887367E25186479103A0C6F7F18602AAABF244BCB00000000
        49454E44AE426082}
      ItemLinks = <
        item
          UserDefine = [udWidth]
          UserWidth = 120
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'cxBarEditItemFontName'
        end
        item
          Position = ipContinuesRow
          UserDefine = [udWidth]
          UserWidth = 40
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'cxBarEditItemFontSize'
        end
        item
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonIncreaseFontSize'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonDecreaseFontSize'
        end
        item
          ButtonGroup = bgpStart
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonBold'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonItalic'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonUnderline'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonStrikeout'
        end
        item
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem1'
        end
        item
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxRibbonColorGalleryItemFillColor'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxRibbonColorGalleryItemFontColor'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarAlignment: TdxBar
      Caption = 'Alignment'
      CaptionButtons = <>
      DockedLeft = 366
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000013744558745469746C6500416C69676E3B43656E7465723BAA4E5DA7
        0000019749444154785ECD91C94E2A411885FB1D5C48A29705A3403128202A37
        022A5C109C808D2B4DDCE8D2C79085BC1234F82084210C01C210C690DF3E65BA
        D284252E6E2767F1A7AAFFEF9C5312116DA5DF59B05AAD3E178B4561369B094D
        A7D3A25693C94408F372B9CC8B05CA50483DBE93FB6F965CC10C39CF1EC8797A
        4FECE48E1C815B72F85364F725C9E64DD28137417A6B8000D13AF850A9E3F1B8
        D8EFF7E56EB75B823A9D0E17E6E17028E31C2E14684E2CC0E70A662567302D21
        4A2CF3462C7043F6E31BB2F9404DD21F939F53F78C5EC9E289F27FB411F22A1D
        14D0DAED76A9D56A71359BCD326638535DAC7580CDD1F42BCFCC446690AF7966
        EB519C2C9E7F647147C9ECBA249D9E11805A0739E41A8D46C5C1602083DA6834
        CAF57A5D0873AFD793718E7B1B1D2899A570F245C2E650E2F9877CA8503D3185
        7C45BBFB3602C4C822929185373B402ED04101AD5AAD7E41954A85AB56AB95F1
        1A38470F4AD9A2034E3D8F3FA16D4DE698C86C765E908945C8C0C26470846847
        672400D73A402EB4AC0A24ADF032AAE0743E9F8B0EB6D0FFB0E01B87A9D41A31
        14381B0000000049454E44AE426082}
      ItemLinks = <
        item
          ButtonGroup = bgpStart
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonTopAlign'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonMiddleAlign'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonBottomAlign'
        end
        item
          ButtonGroup = bgpStart
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignTextLeft'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignTextCenter'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignTextRight'
        end
        item
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonDecreaseIndent'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonIncreaseIndent'
        end
        item
          Position = ipBeginsNewColumn
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonWrapText'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem2'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarCells: TdxBar
      Caption = 'Cells'
      CaptionButtons = <>
      DockedLeft = 606
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000024744558745469746C6500477269643B53707265616473
        686565743B43656C6C3B4F7074696F6E733B89F1EC24000002AB49444154785E
        8593594F534118860F06718DCB4F30C61B6FE04AE14AC56844340495A217B248
        48234B042C36254A716111520A822C424B0B4D65A905B4D29AB0682BBB14ED42
        6862549640D8A2B42CA594BCCE1CA10163F04D9E4CBEB33CE79DE40C43E24DF0
        21ECDA86DD94F57927C10B00436124F59FF5F2C621C8D556C836786541D5062A
        33A4940633240D269429FB0D54E21114CB7BB0396FDA6D5BE7B6AD7381B40B44
        B0C7232892B1022C3BDD58595DC3A075022EB2123CF3F28A1BF64517FB4C7E25
        2BD8E7111448BBF1BA7598D41B80913C1C5FD28DB8E22E709F7522566C408C48
        0FA365022FEA3E41A51B425EF9C7AD021131D2D89756E174AD2134AD05F59639
        D49967516B9A458840439BD0166C2B43FF0815ECF708A891E6D7828B08DC08E1
        6B5033380349DF1494C619DC167510811B4DEF0670F751359ECB5AA9E0409250
        C6DC49AF62989C5203EA3466942A7AD16F1AC7B944154B96AC17156A230A6B0C
        68EFB482475E360D8F2241508188B8EC9B5C5E49685462DE1126B3580F9A39BB
        130EB28DBE2F635874BAE124954B643AF2452D84B9B5E81EB061DEB1446416A4
        652B905FDE8CE8A48216E661E17BD0D81757314FB651AD1E64B7B3B0EC42634B
        0F728A549898FE8932693382AEA6425CAAC2D79129A4E7C871F9BA208D49CE68
        FA909AA5436AA60EBC4C2D788FDFB2144A3BA169B3222241841FE3D3888CCF43
        91448B28B2DABE4FE22287EF5EFF3B99BD848384437F7138E486409891ABC0D8
        E42C2A956D484A9742D968C0B7D169A4DC2F4770185FC000F827243BCE5F49D1
        DE1396E126F70914EA0E986CA368D6768113F90031894F71F2CCAD77DB09BC4E
        9C8E381A10181D46D6D80BD7F88E974D7AF807C638FCFC395CDF004EF871BFE0
        63DB0958096D42F0391594203E7B2919BEFEE1627A2AD7AF7BFD4FB059E4BDF9
        3813D8FC0682B17459A265858E0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem3'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem4'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem5'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarEditing: TdxBar
      Caption = 'Editing'
      CaptionButtons = <>
      DockedLeft = 713
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000026744558745469746C650046696E643B426172733B526962626F6E3B
        5374616E646172643B536561726368BB659C08000002D149444154785EAD936D
        48936B18C7FF7B369FB5E3CB3C6AEACC66E66C94980AF6C1B74A462FE743E087
        2526299812C519A20B03C98A3AC9D2E8E518519F52222A2789ACF99264C58AD0
        322A848E9BBA6992D95496BACD3DDBF43EF7C62AE9ABFDE1C77D735DF7F5E7BA
        EEFB79788410FC2EF128020A4B09A230AB733FF8454CEDE54EFF7AF8EFC6CD6A
        4DFBA39A069DBDF282565F507A2AD96758A369939EB9D6ABAB6BEA75D55EE9D2
        A9EAEE487D466A4D07FC525FF46F84AAF3DA572F07C7C8F0E814B9DD6A20AA73
        5A0E40485D538F6BE0C3383159BE929B779F90AAFA760300BEEA6CDBCF2E9465
        F5F9FF5CEF21D3338BC43060240DD75BC9D1DA7B04C0969397F464F2CB376234
        5B49F3FD3EA23A7D8F9454DFC8FA3E0E43091286FD59BE4D168B2597070E9717
        939356184DA3D8B1F784D16432C3C97941C0032B12C2EB716085B01500F87E83
        2D698AE820365429A70636BB0B8B4E17161C2E78380F122591F0B8396ABA0CEF
        0A8150148C20FE0ABCCB284ECB514600E031F2F4FDF58A6CB9302E468CD4E418
        A46FDD88785FA1D78D71CB3838B71B3C1E81242A1407F2535176682FC0D9D689
        C2132E0010308C4054989F2547F7D31114553DC4DB8F56ECCE4D839B165A67A6
        C0D1B1A2C422E8FB465158A9C390D981A2821CDAA1BBC46FC0B9BCFCF03021BA
        0CA38854E4A17BC08CED294960593EC6FFD3FF151B17075FBEF38505EBF765A3
        67F013D25393E97D39F900186689B34F8E4DCC4091BB09F3AFFBB13B538A11F3
        17D817E626000C3916178C96092BF6E44961EB7F83FCCC784C4DCF8273DA2D00
        0833373D72B5B9F53912625834AA7642124CD0F2E031E667276E02B0DBAC9F2F
        B5689F214922C0BFD53990867970ABB9034EFBAC06808702B12C43A94EC93B36
        BC2DEF389165161B6365BB6A0044049E6A5D4A56E991949C8A77F2AC32929871
        F0BD44AE2807205AFD2DFC4189A66CA0C450820371040EB18198981242610371
        ACF96F64B046FD0FE22625E3DA6A63E80000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem7'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUndo'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonRedo'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonFindReplace'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarIllustrations: TdxBar
      Caption = 'Illustrations'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000033744558745469746C6500496D6167653B50686F746F3B5069637475
        72653B4469616772616D3B4669677572653B647261773B7061696E7415D5C670
        0000022049444154785EA5934D4B546114C77F8FA3E514312E34214D050D5711
        58462DA226A14D9BE82BB80AA245B8AA5D9BA27511116D4312A245416E4C1149
        C309844C94D0D2AC2C1947E7CE9D3BF7798B0E7A61825EA0C3E5BCFC9F7B7F9C
        E7B9E75180029058657FD53CE0D49D4733234AA9AC285EFCCE03A2F9ED2879B2
        668D191BE8EFEDAB0DC3383BD07F2C61FEABDDBC3F751A48D558E304399B37CC
        6E18DE6E68A696F32C3EBB85FF364434F710B5F914FDFE1E2A3FC8FCE3EB783C
        C63800556BAD2414632B6D5AABD18B394C5822F8B04231BFC4EAD01B5A7A0FD3
        D0D246BCB5B9FD9E4500C63A21AE950C1ED09588EE9941DACEF5906E6E2277FB
        094D07D22C8CCD90BDD444E791B4009CDDE9C0581176F92B00A49465A93DC0BC
        18A1A5AB95C6EE0EE646673974A29DCF931F595EF8CAD11ED009C03A0154E20A
        0AF0CA5368B434E48A64BA4E62831217AFF5B1FA6A85868E34F3B950FE86353E
        D982085125402905C0FA7A81FD3664E2EE20DA39F61D3CC5BBDC027612C2DD16
        F713E06C75075BA542321FC520C05D38CEEB4FD3144637493D1866BCD9B3D159
        87D686F372882E0108B11C9511C5C39E8CE2F9C44BC2C0D0DABB97B19A1ABE2C
        4764D2298AC508E77C154084A852C1E141A6033ABAEBA54E79F8BEA641411C5B
        F26BB1005C02700EE7E1F2D9E96494138FAA1A6DE7A5C43A0402501B95C3D1AB
        3786CF241F0905AA535F5D033A2E8D035A01F540DD1F6EA5FACD4DD440A4BCF7
        FC8FFD008E0F555D42FE2EE90000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPicture'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarLinks: TdxBar
      Caption = 'Links'
      CaptionButtons = <>
      DockedLeft = 92
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000014744558745469746C650048797065726C696E6B3B5765623B06FEA0
        CE0000036F49444154785E5DD26B4C5B651C06F0BA8966662ED9C4B828642A59
        28B30C033B2D816119D0C2904BE95837DA420FAC3046D34E2CD1B6A3B4AB16C6
        2A05A183192E8B73CDA099ECC25A06AD2DB7029B61BA281B2223EAD4E81713F4
        D336CAE37B0CABC637793E9D3CBFFFFF9CF3B252D44116394F914424290665DC
        72B793A71C594AAEF43EA668CFFD44A9CBC529EC5292E79B493652F2EB2C00E1
        FC534E38742E8AAA703B72F4FE55CBE014EC431E5C0C7C81A3DDA7916FB7E3ED
        FAB1B554FAD2C00E6E4D2C83FC1F88D843CA791F5C8776B813FAC19368BAE240
        BBBB1FA53D9FE105CB5EC49864109B669151717598005B4936840166ED74AD77
        35B34783E44F332171974133A2C33BAE01348C2D4376D683486306B87A3BC4EF
        7FB54689CE9A09B0290C702BDCCE746B3BB69F8A4354171B6F346742E5BA0CEB
        CC2FB04CAE40E55C40E91933E8561344DA1BC8ADF22E10605B18E01D1959DA55
        7F04D1DABD78B16137E80B4E34DEFC1D1F4EFF05C3E80A949FCC43D0548DC659
        05689B1162F5CC4302BCFC2FA01C7D1C5B5B01D147BD90F50EC2E07B8086C09F
        D0795670BCFF0F1CB6DD46AC390BB26BB990B71D8544330B02BC1A062885FBBE
        D07411D1C78A21EF1887F4633F646D41281C77A168FF0985C6DBD8AA4A07BB35
        0159660944CAD11001C27F83955832E0CA3F7107FCDA3E24C9D5E096282090D7
        21F5B006197417B2AA038897A8917880469A588DD402ED2A9B9B6D27402483B0
        38059D4A816A662DBBCA09ABE302FC5373F8F9D7DFE09BF812667B1F78F97530
        DA7AE0F105B1B4FC03864626A0B37686D8BC9C26026C21616DA68ACF5F12969E
        823F38074B473FA4B52D90A89B515CD30851E549E4951B9153A64756491D8EE9
        5B70653880847D87E609F00A036CDCCE16250AA4EF8598C9124D337ACFF7A3A8
        CA02E6CC2F2CE2CE37DF62BFC280B633DD4829A8C6DD85EF41ED2F7F44801816
        25BBC6205BDE2AAAB9E51DBF05C3E973EB1375109089FB0E1E27EFAE628AE0E5
        5542A9B5E2F3211F386907BE23C08E27F7F9594A28D5995AFA566F04A6B1FCE3
        03B87D933034758538694537755647E8B2C78FF97B8BA4ECC5BBE6D6D0EB09FC
        76E65A3F0136305BBC995E5CCFCBA5E7520AAB1F2609E55FC7F1721B091EB773
        8FD016CF3F782F29877EC449132FBEB69BDF413AD1244F33C07F91E74822D73F
        CE4B24CF933CC3E0EB859DCCDACC64A6CCF4FE06A358007EE055FFED00000000
        49454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonHyperlink'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarPageSetup: TdxBar
      Caption = 'Propriet'#224' Pagina'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000016744558745469746C6500506167653B50617065723B53697A653BBD
        2F129E0000019149444154785E5592B18AD5401846CF971B651FC7C64A740541
        B0142B5B2B6BB1560B3BAB857D01B1F7095C10B6BDAFE3E2DD64FE63E14CC20D
        249929BE6FCEE19F3C7BF3590A4CB8FDF965BEFE71BC990E874B1104000D5068
        C042C2BAFEBDFDF0EEC98B591352520698C9E1F2FDDB475B782CCEB770F5FDF8
        1438CC2A548002486B0B6D2D96266E04A324085C3C0CB516C034538511A01740
        01557B08820546EC4A6B6B0099558254F582A581A262828A00615B5B70FF9F80
        D908CA80B86F85842228E0AE50084253DA3A089A10E9C4A9D650A81203085520
        821BC9B9026C04599642A4740F03BD020A4AA82A80CCB1514E4401B2D68A05AD
        7A681C2C140060C1DA1C042188B12BEC049C8D4FEC34CD1A0A74858D739BBF0A
        A6A38BA3CC09856A7D0A54690410B838DDDDFDFEF4EDD7F3B3AB9C117640713A
        FDB90596598D5386E074FDF5F52BE00190FE8E27FB1F810538E5F1CB8F50450E
        DB65D224696284DA29A268303281C79BAB4CB161A41962775D4BA3AA46A14CFA
        260A0C6DE6AAEE38C209891149FADC81697C5A480411E01F472A7E2E7DA1EEC6
        0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemMargins'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemOrientation'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemSize'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem8'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem9'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPrintTitles'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarFunctionLibrary: TdxBar
      Caption = 'Function Library'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000024744558745469746C6500496E736572744571756174696F6E436170
        74696F6E3B466F726D756C613B6E88C6260000012B49444154785EC5D3B16D83
        4018C5F173740BD0A648419DEE18E152A44815D92B30C231823D823D028CE01B
        01468847884B1B2271F99FF42C2548A95CE4A49F1ED6FBF824045EA594CC3DE7
        01779DD5EBDB7BCE122D1C0EA8B14640657452CA917AB22607D258755B2DD951
        7A4A4FEEC99AE4C6946949DAE1880D5DB4F33C531AAFA146431F38A0D3829F3A
        386CE73955769ABE5ABA42658F0625227A869CBA08AF052C3781CEDB719C365C
        7C6AA842D0F599A8E88EBA71C00E118EC526A7BD5E27A31F3785F2A4A1063D3C
        9A5BA7472BECE5322E9FF1AC2C8981BCC96FC893511D279DF323FC5AC019745D
        6828901DE9C8907B143018568F4FCFADDEB95159A1478487C3092534A38E594B
        B1C1F2346851A35B746BEC75DF9F9F72C40B029627A0D68CF9F73FD3FD0BBE01
        CAC458B9CD3BE9DD0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemAutoSum'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemFinancial'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemLogical'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemText'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemDateTime'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemLookupReference'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemMathTrig'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem10'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarDefinedNames: TdxBar
      Caption = 'Defined Names'
      CaptionButtons = <>
      DockedLeft = 537
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonNameManager'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonDefineName'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxRibbonGalleryItemUseinFormula'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonCreatefromSelection'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarSortFilter: TdxBar
      Caption = 'Sort Filter'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000000F744558745469746C6500536F72743B4173633B1714349B00000318
        49444154785E4D915D481C5714C7CF9D197775EBEE66B7EBAEEBAA0D9B982AD5
        F8508B8A26246C03ADB67DD07D488BFDA0054B9282425EB424A14D2A2D94907E
        A28534D042852E7D8AA1848A4593B2D4D692BE08123621512462B4D5AECEEECC
        FD38BD77674A73E070FE73CF3DBFF31F2EF9E0870E3893FE959CCFB4CF00E051
        90C139CEBEFFF2EFA923E9718188A0EB3AD885CDAA0A7FEC816D59B0BD71AFC6
        E7AF59472140135CA8192284387AF2A58BA0325F308F94CE3807953F67DE269A
        EEEBA1B6751700FF313CC19EECB5614D080E1A73015CD66D7A1BEEE433C029FF
        0F0A4294B4C639F65805F3A6606C5EB67A0140E7B26770E10014880B1B38E7C0
        283A00267B1A40247ED05BE6F11E33F31BA7392351A27947FCA1A477E1A711A6
        31E63A90950A4B26054ADD33A9B353C3DADEE6BEEE9D7C3E24D073C5F0043E22
        40F6241A7A0F29671A73ED5259192F02658F024A5547D07B39A3AB0BD323E13F
        662E4425604B377CEA370C833A0E4A43162B80CD2C60CC8122772AA7784C707B
        5AEA5DCBDC203BF9CD59423C29D533A8ED5CB229970053026CB06DF7651C27EC
        CFD9736DE004AAB298FDF055D5573D637C68C92345B96533395C004B397006CB
        6FCD9D4105C83EFDD43CA26866024123046C8EB065EEDEEDCFAD349281B17D08
        280011E195E329F8DB5C86CCE4A2FA2EE5B58FD77C0040DD8DFAE7C9FACE5A5D
        FBF1A155FC747079EDACB6723FFFC993FB1BE0CD813EB97D57D26D78FDB543D0
        78E000E472E62500E0571BEA99AAEFD5C5A3098D7CF757B1382787CF2B771088
        95050E0F467E199B6AC789DF3A7162BE1347332DD8940EDC280FE941F55432C9
        B341FF9EEF93750B5712D5B97E7F65AD72F365550440896457E5FED43BD5EB17
        67DA70EC7A2BB60E8456232DDEA4EAB9D62BBEDD9B98FC3A1EDB1D0A073BD5F3
        7D1609C3A57008A0E3ADB08294353DEF7FE1C5D104ED3A11B112DD152975E60E
        974DD4D59CFDA6368EA3E1D02900506B03321F2B2D78E68D10B817CB5BD28177
        9F78CE37A4B43ADBD757094A5F8EC7962EC7A3F8553482E391C7F18B70082F04
        024BCA1981FF435344577399C2D5BA0B34DC45E4913BE6BFC269869883B528DC
        0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSortAtoZ'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSortZtoA'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarGrouping: TdxBar
      Caption = 'Grouping'
      CaptionButtons = <>
      DockedLeft = 182
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000012744558745469746C650053707265616473686565743B
        986723090000020749444154785EA593BD8F4C5118C69FFB31436CA794F81B64
        A996CC4E62488815C52E0A6A44610B3311626C36223E8A4D1432ABD088024122
        56083342C6160A422442748B6255AAB973BE9DF7DC77C6CD24A2F024E7BEE79E
        FBE6779EE7DE7323E71CFEA6C80B4002201E2C71753C748A82764DD799E7807C
        52BAD46A7792249DC488B456DDD3C777D68A0038EBE00991BF82B546493779EA
        4415A39A5B785A2177A97719B335ECD8378BF6C3AB69C1626CAC85D216DAD821
        B694C4B0D68648E9DC8DDA0B8FA89263878F98D8BB5DD1DC18FBEAE2B1975379
        237B7254A370670D033CB97A64A6119A8AF9AFDDBA42BE130FC2BDA50FE8F555
        007007CCC081141A2BBF96293B9A676E62FEC2A13017C280229083E93D9B20B4
        016740B994E0ECE5A500888534905A60B1F5181B36AEC7F5D61348D387943A34
        18CEEE5C1400CC803526072861A0740FCD7A03C6389CAB9F84529907B0030F60
        026C288E06F5E611845410A68F2F3FDB683666F169B5437C280270D6BB8FDEA1
        97294E1F1120AC93D2AF9F573B0BE79FD5729BCF87E7CC6727922307FBA7C691
        1190B5B69CA03EFF2077D0BDFD63371FD768CBB683BDB7CB77D6F1566461CCD0
        E11A588F861FE9CF39F00FC81B0D6CDE7A00E3133399E3CCEFDFDC77FC12FDAE
        298AB21E4C2AAE12951292C01AFBBEF2AD7BF8E862052352327B4DE55F7F6342
        910194E9162C8E2801F403E07FF41BB9CA411120F2A77E0000000049454E44AE
        426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem11'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem12'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarComments: TdxBar
      Caption = 'Comments'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C0000001C744558745469746C6500496E73657274436F6D6D656E
        743B436F6D6D656E743BC72A3AF20000026049444154785EA5934D48946B14C7
        7FEFFB4E5F6823F40119EAAA4222FA6E6171ADC01642112D5A5E0351B810B40A
        82AE343442446D6A8AC03661090605952E922EA6D6222A53E9DAC888292461E9
        A8E838CEC7FB3CCF6926C7715CB8EAFFF0E7F0C03987FFF9B244843F81871510
        BC7E084110112C48DB2B805F842B88F805D85DD78BC74A0170009BE5B0C8418F
        6FD7556DA4C2B6F8EB80FF4B7D77DD4E5974F2F43CA86A776CA71C205B9240FE
        9652D4C43766075EB3FF7C3D91EFC3E41796D07D372D027FD98D419F0770743C
        5EBEA7FA0E888018C848B7EDD59062FFFD5A66426FC8F35A4CF7F69288B99D96
        2DBEC51E585A1B2431819A1B01D16034A0B1566D64F4ED4BC2C177EC28AF6166
        A887820D5E5432714CE0774F6CC0324AA363E3B893FF63A263E8F8142619C5A8
        1825C7CF72C4F798AEC03D4682113A1EB651D13096E7265D7F760A4A69444531
        B169F4FC14820163101110CDBAE24A8A0E9F64DBA95AFA1E0580664B2B97A512
        5C8571E7538C23BF030D6040D21492530314ED2B45CD0EE36C2A0640BB662981
        520A4944308918221A44322A16ACF9F90911C12427190F7D5C3662CF42368D49
        4670D6178231E8D824CE1A2FB050828880D1984414E52A004E37CF6613A8C1E0
        6867E8F2AD63225075E94C7A7474B4BC67A4EF2B0018301800347617A07215B8
        179E0E5602054DFF1CFC01161DAD1F686DE90F3486E6AEE63A0392F927C9C5CD
        135B01BC8DD57BE5C9C532F97B7BFE6D200FB0C3EDB584FFAB21FCAA9A89B673
        5C3BBA99CCC6A699E981D100C675152F9E7F0E340D45FF05622967D3E07F06D9
        ED1690950FC601D6023A23D1B032B237F30BC04E554555629AA9000000004945
        4E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonNewComment'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonEditComment'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteComments'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonPreviousComment'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonNextComment'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonShowHideComments'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarChanges: TdxBar
      Caption = 'Changes'
      CaptionButtons = <>
      DockedLeft = 523
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000029744558745469746C650050726F74656374696F6E3B41
        63636573733B477269643B53707265616473686565743B190E0BF40000024849
        444154785EA592CB6B534118C5CF243769A20946452A151B5BD01694AAB47561
        351405A9A8012954D08DA00BC50716FF008B1BDDB56AC44D2DA8AB88F8202216
        6BD198D82E0A3EBAA8813E521551A369316D4CEEDC87F79B4CA801838207EEDC
        F938CC37BFF331CC344DFC8F98FCEC006CA22EAFA247371A0034D3924287AFDF
        7E3DA8389CDB61D11479FEB4A785769CE763C70E36EF00C0C976856E0C9BBF2B
        329828AD9F96D63D7D2F89C24DF1898015C790CBEB822DF57D0ED99C26084C59
        CF59B5C2001B039A1B5681C8CF9E8F885C8B7AFA86E66BAB972235332F3129F0
        02F6329F1BFE2A2F9E0F4FE2C3A71FA8AAF460A03FB2BEFF5EF79820D00D13FB
        76D621F353036185236F7060EF469832F3D474CA3A3C8E95954B10DCDD80A191
        24FC6BB7F402088806866E8064180568FA19727084E8541826A7D3686A5C8373
        17C238727897E5B326B2C8F75CBCF62253B3DA87F46C560E5DB403A9A5B11A7A
        AC0B6C664CD0495F2C2AD7638508BA898E3D1B90CEE485197EF00A1DC1CD82C0
        69D330FE75149B4E86049DFCC46FE4D2896DD4009A8CE0B0DBC52D5E8F0B0EC5
        5638A09BE02A873EFB167A7A14ADA7A6F0EC4A0DECBE7AF03C1711DD9D5DF71F
        2B4E57403E141A06AD620EED6DEBA0DF6DC7D6434168D96F387A3987DED31550
        2ABC88DE7C04269FB08B00CA3CE5C5039DF51F5BF7D7015F1268E9AE45FCCC04
        B0C28F277726A058C8C49F451931C6349E57013503836B885F5D0EE35D02B6DC
        1C34558382BF4B4FBE37A2B742C90084E2D2F88C9CC6A2FFD2403DFE30D906C0
        591A518C89FF02E57C3DDFFEFE45A00000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonProtectSheet'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonProtectWorkbook'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarZoom: TdxBar
      Caption = 'Zoom'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000000B744558745469746C65005A6F6F6D3BCF09FEBC0000035A49444154
        785E7D936B4C1C7514C57F33BBB0BBBC7641046A2AD0D242B616ABB605D41462
        7996F8819268254693A6311AF41BA6180214A4055A959AC6588DB18FB0049342
        237DA821585B405AB1A948080F53A3B5B42C9447175876766699BF5308899F3C
        C9B92737B9E7E4DE0F1721C40A01D3C79F77EC38F54D5FFBD9B6FEFB67DB6F8A
        33E7FA27BF6AE9B950FB514B26100C486BF3D547DB015869720BF759BE7475D7
        B67D37A88EFE392516BD7E616045476E4F0AD7F9FEC0E1A6F39FEEC8C87500B2
        E1E1FDDA16D660FAA2F9DAE1CEEE31A16ACBE287BE7F44F5C95FC581DAABA2CA
        D04BBD7F0BEF922A5ABFFD4594D7B95A011B2095967F0D80FCC9C94BDBA31CF6
        83BBD236D2E41AA4F3C63D0AD2E229CE4B25608DA2A3D7CDF1D62172B2B6E270
        D85F2B39F0E11EC0E4F3F901904342EC155B926383AEDE9A60CAE3A766FF76E2
        9F70101F63E3796734492949B83D1A3FDD9CE099D44482ADF652204851140064
        1D9196B83E8A1F6F8DB3775722F37EC1AC6F9939839884618064E77A6E0C4FB2
        31218E40403C07981545E5C25BE9C89AA6AFB35ACD3C58505892830C73803925
        C0BCA61B5C263C44223A3204AFAA116C09C6AF6A9180E1D3305BACC88AE29F5A
        F269C6908D2BB73D8CCDAA3C547566D4004B0822224CE8928AC36165EEA11763
        F579004D0BA0EB3AF2C282B767E48F09763A63989D79C0A8C7CFC8829F2509C2
        C34D58424CDC754FB32DE9318686FFC2E75B1C00960D1845204FBAC74F5DECFC
        8DF4CD51C44698718FDFC32C544243C1A72A0C8EDE415AD6D8141B46C7C51E3C
        3313CD802684BE1220019637DEFDECF453290925050569FC7EDF38C3ED61DAD8
        22CE6E2525CEC106870D97EB32E18B6344DEF9BEFE83CBC34781C573FB5FD065
        40FDB9ABB9B4EFFAC089A6136D3AD3D3BCEC5CC77BBB9DE427C7B078779C63C7
        CE10ED1DA2B67433D9D9CF561CC9771E04425F39DD27AFFD810C583372DECECB
        2EAAE8CA2D3EA4E4141F12D945556A6661D9B56D19FB4A2AB3363474D7BF2AC4
        40A3B85EBF5754BF94DC08D8FFFB4C1260066C4038605F2561800588284B7FB2
        BEABB25088DE32D1539927EAF2B71E917617D5201020745851C12A044820B1DA
        5FE9689081B0779E8EAB28CCDA549E9F9380CB35E6E5FFD0F2FA4E1A3213A87B
        319E9A8CF8B55323DE4C7EBCEE78EE16AD714F6ACBBF059CA12764F2DBD90000
        000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonZoomOut'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonZoomIn'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton100'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarFreezePanes: TdxBar
      Caption = 'Freeze Panes'
      CaptionButtons = <>
      DockedLeft = 189
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000022744558745469746C6500477269643B53707265616473
        686565743B526F773B436F6C756D6E3B69896E610000020749444154785EA593
        3D6854511085BFD9F762C4253F1BE3B2899846B3AC6C0A8D622321DAF907C2AA
        A095C4C24E14B1B01509585AD848C0B46A8C200876EAAA98A051D108AEC986A8
        E98C865888C9FBB923CBBDDCC622850F867B67E60CE79CB93C0102405CB07678
        9C022A1746269E8A0483A8A200AA18B527F8BB4B1503606C9EA6F133397F7352
        4F1D2C83D81915A536FB83D2B64E507144F071E63BE5621E3C3D8C8EBD214C92
        14A3CAC2F2AAEB08EFEB8B6437B6809B47607A6E91B67C1B8ACDBB5B9B89E304
        397BBDAA3B4A5DD4BE2CA14EEAF1F933A8C1E6EEC428F77A47BDCDAD3D1DBC9B
        FE4698C48672A940AE90F374C927C3C0A561AF4081C7572F337C7AB7B7D41466
        B856AB133664A83196CD35A395044D13925F35C4398EFEC4BEEF6A1855E4E495
        47DA57DA4CFDEB4FBB4494CA87212BDD6EDB86312C57EE82082814F2AD3C9F9C
        6D2848D9D3BF859EDE3C4E33B7A3116E9C1BF07C02DC7FF896CAE19D28780BD5
        89CF8D1DD85750C5FB4BA3D40371C23D06CF83318A1CBA38AEA56237F30B4B16
        E06C1CD8DE6E917E0AD4F30B9DB92C2FA7E6EC2BEC1F2CD2F73B726061FCCE6B
        8E1DD9E5D900C61E4C71E2A8AD29425390E1C5AB19C2384D49D5D0B1A1095451
        81C2A616C22003A817916BCF1264022FDF5BD83B74EB491034EF53B15B07EBB5
        BF6B1D80CB05C013A0B616472B5501D603E11A7FE3BF3D50201155E57FBEBF66
        872929D924CF9F0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem13'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarConditionalFormatting: TdxBar
      Caption = 'Formattazione condizionale'
      CaptionButtons = <>
      DockedLeft = 903
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C0000001C744558745469746C6500436F6E646974696F6E616C46
        6F726D617474696E673B4AEFC1C8000001D849444154785EA592BF6B55411085
        BFB9B9512368FE066B111350448B04C1C2CA464B21A9C4C268696321A6086904
        15B1321AB008446BC18024FE2A6211B591F4064494203C13DFDD3B732C9677B7
        13C403C3305B9CEF303B065480E5FA67C9EE2EACAD56D5D0248004204E6DCD40
        8014284012847877E801480CD486AFD99D85D7BA7CF12400020CF8786B9CF199
        DB791008589FBFC6B1B94F40C97AEFD15BEA709101606648A2D96D91B7786F13
        0340A49D060984408619B807B587D020BE84AC448C5F5F3A03C8106120315419
        DE8A7AF2F92C9F57F7339010AAF7F2E6E60C0A656A802278BCBC81C81A3DB08F
        36825A218E1C3F0C0229B008DEBFFCC9D8B375064B10B0F8F40353E78F0E2854
        43C6FCFDAFD429258820B67F408E47DAED230995D5E659E58580D645D5EEF451
        4A2072D6709A7E4308A27C23112224427906E11ED8CA89714981A4522136AF3C
        ECE820B698461D5D007CDBEE51BF3837C78DABA7F128F116973798BE3086289A
        5D0ACE9E99C864390AE7C9D20AB57B10D9B4232A4400489D494A4EF23EBDE63B
        AE00822689DA5D205155E5C4460F8E5099C0AC334D8DD34F3B34FE9B9040C2FB
        8E5DBABEBC36BC6764C20A2D7795BB0063AB99A21C5CEEA9D12B034680E10E5F
        64FC5D029249E27FF4079DEF5285AC55AD1E0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem14'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarMode: TdxBar
      Caption = 'Mode'
      CaptionButtons = <>
      DockedLeft = 364
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        61000001B249444154785EA5903F6B944110C67FB3EF45BD4263A7955848B453
        B1B1CA35A29D45A208161204FD0AE23730ADA26524F5A97D6CF4045B8D45C034
        828D7FCA3B0289DEBBF378B7BBBCDB09E2C0CE30CFC26F9E19030260E9FD7BC8
        1E6F8CDE86D00C00A494516149AA008100AA46EB71D4136170EFF6E58C2B365E
        BEDE65F5EAD9DC15E4ABAD5D5692D6C93C79FE7ED0F328247081992189C9E480
        E81969053C9E69528621C30C627442F424E54F178E5245052C41A99EAAE19EB5
        D80A5B7FF646A74F9D60BCF70B2C7F4CA74E0D2155E72AEAE2D1237CF9FA935E
        1BC5F52B4B795231BC31DC666DF57CD70BD87CB1CD9D1B170A134263AC3FFD31
        03B48E03310A15BEDC91BA0EB0DCAB2A38B45184797279D93523E4947D1D3909
        E6AEEE0E19A474447BF8684B4B674E329EEC83EA8ED4E95D4D594266B31B1C66
        E7F3F77C83956BE7885EED6D0E3FB276F3628525ED03776F5D4212668605E3D3
        CE377A313A0EB8A8935C4943EA20EE2087B6ACDA3486BBE6802C8440B10B8BC7
        FA041358B57F7CA611A0515684926BBBFF60385A38D45FB63A0D7509B26AB557
        5D6CFA7BFF9D017D60A11B5FC3F87B08989A24FE27FE00E7662A205098622200
        00000049454E44AE426082}
      ItemLinks = <
        item
          Position = ipBeginsNewColumn
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonSingleSheet'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonMultipleSheets'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonMultipleDocuments'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem16'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarTemplateSections: TdxBar
      Caption = 'Template Sections'
      CaptionButtons = <>
      DockedLeft = 606
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        61000001CA49444154785EA591316B14511485BFFB76A22CA206D45A5054141B
        B1B172B131A91511AD44D052102282F80B526A65A3582F4965B3DAB882D829A4
        4B208AA6B14884C495CCEE9B77AFF1F266060405F1C270B91F9C731E73040880
        F8F7EF63F2E8E9F075089D9E5FE60CCB5EE6208F815F2DA3D2342C8CD0BB75FD
        9C0303972EBC5CE6F2C5137ED5968B83652E396B308F9FBDED159ACC4DD54044
        3C756BAB24A94B916CBCB9C3CCDC0C4C1081949490D4919B981A8AF9C66A6383
        BCD5B7A0EA8C541932BC77D242D12507BA28952317B5CC53DD3CA7F942A18851
        E9CDCD633A7235182B2F163836330B8088635606038ECFCE403695622F830777
        29D25849DB5F49A3CFB9476163F51347BEAFE578677C5BFD48DAFC92BB13C2EE
        69E258292665C2E2188B5553602C158D1111F37424B3AA6ABAB21089134516AF
        1DB643474FF1637D9DDF4700FBC3BDE7C041D6969628DE9D7EC2C33B17486A90
        05CFFB1FB871E54C2B76F69E9B57CF7ACD228204A13FFF8A22254501B55A2EB9
        CEF66F03A882295466CE3B1DAFF397810342C0C500FBF775096220D2984EEF30
        0274EA26317FB5DCBEDF1F4EEDEA9E9736CD777D3845DADB8C7AE264FB8D005D
        60AA896F47F8FB1810C51DFF637E023D7B1F38D487E66E0000000049454E44AE
        426082}
      ItemLinks = <
        item
          Position = ipBeginsNewColumn
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonHeader'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonFooter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDetail'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem17'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonReset'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarSortGroup: TdxBar
      Caption = 'Sort & Group'
      CaptionButtons = <>
      DockedLeft = 870
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        61000002C049444154785E65526F48535F187ECEEE1CFDD7A4280A057506F9A1
        0F4248C1B4148B7419A16530095AD0C798266248500449089A261145EA878C66
        51D6EFE746D13F4B83024D90ACE514874C67B8E9D431BBDBBDA79773AF81F8C0
        C37B9E73CEF3BCE79E73D9AB8B7B3E488CE5710E80C8554E451F732E34C0B44A
        3AA6F0DE13EDE305B4A68060448CE759EAEA350761FCDD27A4E75B8409E09A3E
        9C4B928B50776D751E0003510B909715280B7EA87FE684C13FF00529FBB6029C
        81B1D59A80982C7C42888018050C74BA1109CE62057D777BF4FE1AFA49AF8CE3
        325F1D306AE9C031BB05AAFEED6D5D83B0976703D074BBF31BECA7B3C17557E3
        BD8FC08B827F0186B8C2B5CBD27B2448128C0640621C06AE22FF402A684A988D
        548FE46688C68C31102920AEC2DDEBC5939E1138FFFF8E049304EFC42CAA9BCB
        70AACE8C3BDD173046DAE39DC19BCFEFD1E02C42CEC9ED3900A4E2CA1418E904
        389A670605892E0F9C8348DDB5051381213CAC7F8E8ADA52ECDEB111E1C520EE
        BB6EA0DED1802B2D359DD142F5604FD3A44F9C80AB1C2A002A62AC28A4B801A1
        E56171CC70781ECD5D55B01DB741367971EE4CD98ED4ACC4C73BCD1B928CD168
        F4C3B55B6F0F31300AE0E21423A33300230D453C5FFBB336BCEFEBC5AFC9215C
        AA2AC4ED8ED7F0FB16F6276798CE83B08EB889B8999848DC464CB33AD2F8F760
        13B756A673007B895956473A7F3956CA8B68CEE572950358AFBD804E4242C1F9
        D41ADA48C60CB1B998AAB53293E7DA52AE5A1D66DEED2D116B0092AC8E4C18B0
        1ACAD7FF021D015FE49BBDBC048A2AC35E6EC5F4C4E2D0A07BE6119801713506
        40229297B13501EAE26F3934E559B235B67605E7E7A3686A7D1AF4FF58AC580A
        C9730083220218911417016BA04C8D44C6A646976C2DD787C3D3DEC8D9C0CF88
        174074D213EABF7979183ECFDC67003227FBEA3BD0A1B730E9976BD2B5A45F74
        B2A89AC65F50ED69BF30EA98540000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSortFields'
        end
        item
          Position = ipBeginsNewColumn
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonGroupHeader'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonGroupFooter'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarFilter: TdxBar
      Caption = 'Filter'
      CaptionButtons = <>
      DockedLeft = 1039
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000035449444154785E65906B4C93571C878FC088810916E9C00E71821831
        8212CA7AD7512F4075E38319CC41A843870C5D3A565833B0B06E14E5A2300695
        22BA2DDB60BA912086E1BA395D1B68B99A99E02E6165BA0DB4086684420AE86F
        E7747409DB499EBCEF9B9CE739FFF710BABCCF1FE56FE8D4484A4CC5B2EF4C45
        D2E16BC5327C5B24C3558D64F8AB42D1F5F67C61E9D957B647B1BD9415008807
        D2512056F73564BA266E5DC29C6308F37F8D60C17997F21B16A66F6376DC0CC7
        4033AC352FBA2E1D4B28609165816F8AA433F30F87F1EBD573B0561E416BF21A
        5C5470D0961A8CCB69A1F8A131077F9A8D703DE846A74AF090067C9705AEE48B
        3AC6CC65989FB4E0D1DC1816E9E98BB3A3143B9DE2474C8F7461FC460D465AB2
        F0652EFF0A0B1C503F433C90D6D7F8794367D33177C74803A3A0053847ABE0E8
        7E1EF696FDE82988C140493C7ADE7B0EEDDAF46216A0F878EE83A43DCB5BD3F9
        A6E8DE84ED5DB8EE9B68E42E9CF65ADCBBAEC0CF46396C6F6DC3CD9362984F1F
        9E542A44E18ADCB0F254D53AA4E43E5D4E034F10566BCA8ACDB2E89331D55F06
        97C382E95FCE60CC9484E13A193D3D01838D7968AF78FDC4DE23BC0AED05111E
        3DB6833D7729434F113606C5D77070EB619346B6F0D3674731D15B8AD1B64458
        DF4980F5FD9CC5B6F2E33AB932A4FAED66815BFEE2E601A4AAC2213DC80569CF
        8DFF37A2DB1F95D2F27204A6FA34B07F244197360D067546F6CE8CA74E6B8C7C
        B7FCF9602A52F27850D56EC73645E01962AB7E810C54483D9180968C08CCDCAE
        C1B8498DDE4F2B21490BAE531BE2DCF227FDFBB027271479555B112D5F554B1D
        3F62D627933EBD80F4EB8584055A332331FB47071C431FA344BB0FAAFA58B7FC
        A12D0989D95CBC5A1E8D48B17F1D959FA478916B5A39E9D5C5933E1D9F05022F
        2AA330737F08372ED720E38D18B7DCDC2DC70E65300EE936213C7E653D155731
        79BD7025215D6AC91252C2AAF41D3D4DA5D0E4EBF0417D299CBFDB20CBE42253
        BB116B637C1BD8944C365A76125E9C2FF9EFF259AAAF8BDB5368BF65FD1AD515
        051027AD0777B38F814DC8E486EFA5C440E16EA1DB012C43F812C77D179C3039
        02420477FC385B1AFD82FCE59E7F0EDAE44D82A2FE6175A4F7FF0382F4D59E49
        D869ACE6BFF4BD2230C28B046EF02201140E0D44EFF6277F0355F3E806810A3B
        9E0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonEditFilter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonResetFilter'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarDesign: TdxBar
      Caption = 'Design'
      CaptionButtons = <>
      DockedLeft = 1147
      DockedTop = 0
      FloatLeft = 1192
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000016949444154785E9551B14A04410C4DF6C655EE77041B912DCE5AF007
        14416C84AB95FB010B412B9B6B2CFC04B114C52BF483943D772671329399B088
        850F96645F5E923733385FBEBF34CDA4436660008821814B021849022E3970D2
        5008AF77E7BB33078CDDF5F1B61454A0D0FFF9F223A6A546B600A08BA1713E50
        227C1007AC3B4A3F43F052D70AAB335BD6380A4590412C256508E1E6742735A3
        69A0DD68E0EC76957237F87C3EA6F8A136334B6E9BAD595D88E32004BA3004E5
        B90CC920A889DA1754ADF789C074075C6522D461DA8068E60D083E781DE0098E
        AE9EA5A182ED4901B5C0CA4BA28C1EC1077858CCA05F930CB627C3DC7022C3AB
        7141D5D8118055C026289A10C81AABB391832C20667D86320C93E6FE721FCC74
        C674D3C1E1E2697489A32D1A8DC352B33144393AD223982DD36261C8D8328C88
        F4084CE9B2B6DA892DE2F156C36FCE0DFDD7DBC1C5E31EFC137EFDB98A61903D
        D3F8B5B6D350B83F3C7CC7D8FF00AE3EFF37FED19F050000000049454E44AE42
        6082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDesignView'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonReportPreview'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBar1: TdxBar
      Caption = 'Custom 1'
      CaptionButtons = <>
      DockedLeft = 1278
      DockedTop = 0
      FloatLeft = 1036
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton1'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBar2: TdxBar
      Caption = 'Custom 2'
      CaptionButtons = <>
      DockedLeft = 753
      DockedTop = 0
      FloatLeft = 1173
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton2'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarLargeButton1: TdxBarLargeButton
      Action = Chiudi
      Category = 0
      SyncImageIndex = False
      ImageIndex = 60
    end
    object dxBarLargeButton2: TdxBarLargeButton
      Action = MostraFormule
      Category = 0
    end
    object dxBarLargeButton3: TdxBarLargeButton
      Action = Elabora
      Category = 0
    end
    object dxBarLargeButton4: TdxBarLargeButton
      Action = actSalva
      Category = 0
    end
    object dxBarLargeButton5: TdxBarLargeButton
      Action = actShellExecute
      Category = 0
    end
    object dxBarLargeButtonNew: TdxBarLargeButton
      Action = dxSpreadSheetNewDocument
      Category = 1
      SyncImageIndex = False
      ImageIndex = 1
    end
    object dxBarLargeButtonSaveAs: TdxBarLargeButton
      Action = actSalvaConNome
      Category = 1
      SyncImageIndex = False
      ImageIndex = 92
    end
    object dxBarLargeButtonPrintPreview: TdxBarLargeButton
      Action = dxSpreadSheetShowPrintPreviewForm
      Caption = 'Anteprima'
      Category = 2
      SyncImageIndex = False
      ImageIndex = 169
    end
    object dxBarLargeButtonPaste: TdxBarLargeButton
      Action = dxSpreadSheetPasteSelection
      Category = 3
      SyncImageIndex = False
      ImageIndex = 85
    end
    object dxBarButtonCut: TdxBarButton
      Action = dxSpreadSheetCutSelection
      Category = 3
      LargeImageIndex = 65
    end
    object dxBarButtonCopy: TdxBarButton
      Action = dxSpreadSheetCopySelection
      Category = 3
      ImageIndex = 62
      LargeImageIndex = 62
    end
    object cxBarEditItemFontName: TcxBarEditItem
      Action = dxSpreadSheetChangeFontName
      Category = 4
      PropertiesClassName = 'TcxFontNameComboBoxProperties'
      Properties.FontPreview.Visible = False
      Properties.FontTypes = [cxftTTF]
    end
    object cxBarEditItemFontSize: TcxBarEditItem
      Action = dxSpreadSheetChangeFontSize
      Category = 4
      PropertiesClassName = 'TcxComboBoxProperties'
      Properties.DropDownRows = 12
      Properties.Items.Strings = (
        '8'
        '9'
        '10'
        '11'
        '12'
        '14'
        '16'
        '18'
        '20'
        '22'
        '24'
        '26'
        '28'
        '36'
        '48'
        '72')
    end
    object dxBarButtonIncreaseFontSize: TdxBarButton
      Action = dxSpreadSheetIncreaseFontSize
      Category = 4
      LargeImageIndex = 332
    end
    object dxBarButtonDecreaseFontSize: TdxBarButton
      Action = dxSpreadSheetDecreaseFontSize
      Category = 4
      LargeImageIndex = 518
    end
    object dxBarButtonBold: TdxBarButton
      Action = dxSpreadSheetToggleFontBold
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 324
    end
    object dxBarButtonItalic: TdxBarButton
      Action = dxSpreadSheetToggleFontItalic
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 339
    end
    object dxBarButtonUnderline: TdxBarButton
      Action = dxSpreadSheetToggleFontUnderline
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 358
    end
    object dxBarButtonStrikeout: TdxBarButton
      Action = dxSpreadSheetToggleFontStrikeout
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 347
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'Borders'
      Category = 4
      Visible = ivAlways
      ImageIndex = 248
      LargeImageIndex = 248
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBottomBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonLeftBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonRightBorder'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonNoBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonAllBorders'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonOutsideBorders'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonThickBoxBorder'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonBottomDoubleBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonThickBottomBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopandBottomBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopandThickBottomBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopandDoubleBottomBorder'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonMore'
        end>
    end
    object dxBarLargeButtonBottomBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersBottom
      Category = 4
      SyncImageIndex = False
      ImageIndex = 250
    end
    object dxBarLargeButtonTopBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersTop
      Category = 4
      SyncImageIndex = False
      ImageIndex = 261
    end
    object dxBarLargeButtonLeftBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersLeft
      Category = 4
      SyncImageIndex = False
      ImageIndex = 255
    end
    object dxBarLargeButtonRightBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersRight
      Category = 4
      SyncImageIndex = False
      ImageIndex = 257
    end
    object dxBarLargeButtonNoBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersNone
      Category = 4
      SyncImageIndex = False
      ImageIndex = 256
    end
    object dxBarLargeButtonAllBorders: TdxBarLargeButton
      Action = dxSpreadSheetBordersAll
      Category = 4
      SyncImageIndex = False
      ImageIndex = 248
    end
    object dxBarLargeButtonOutsideBorders: TdxBarLargeButton
      Action = dxSpreadSheetBordersOutside
      Category = 4
      SyncImageIndex = False
      ImageIndex = 259
    end
    object dxBarLargeButtonThickBoxBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersOutsideThick
      Category = 4
      SyncImageIndex = False
      ImageIndex = 260
    end
    object dxBarLargeButtonBottomDoubleBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersBottomDouble
      Category = 4
      SyncImageIndex = False
      ImageIndex = 251
    end
    object dxBarLargeButtonThickBottomBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersBottomThick
      Category = 4
      SyncImageIndex = False
      ImageIndex = 252
    end
    object dxBarLargeButtonTopandBottomBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersTopAndBottom
      Category = 4
      SyncImageIndex = False
      ImageIndex = 262
    end
    object dxBarLargeButtonTopandThickBottomBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersTopAndBottomThick
      Category = 4
      SyncImageIndex = False
      ImageIndex = 264
    end
    object dxBarLargeButtonTopandDoubleBottomBorder: TdxBarLargeButton
      Action = dxSpreadSheetBordersTopAndBottomDouble
      Category = 4
      SyncImageIndex = False
      ImageIndex = 263
    end
    object dxBarLargeButtonMore: TdxBarLargeButton
      Action = dxSpreadSheetBordersMore
      Category = 4
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxRibbonColorGalleryItemFillColor: TdxRibbonColorGalleryItem
      Action = dxSpreadSheetChangeFillColor
      Category = 4
      LargeImageIndex = 426
    end
    object dxRibbonColorGalleryItemFontColor: TdxRibbonColorGalleryItem
      Action = dxSpreadSheetChangeFontColor
      Category = 4
      LargeImageIndex = 330
    end
    object dxBarButtonTopAlign: TdxBarButton
      Action = dxSpreadSheetAlignVerticalTop
      Category = 5
      ButtonStyle = bsChecked
      LargeImageIndex = 320
    end
    object dxBarButtonMiddleAlign: TdxBarButton
      Action = dxSpreadSheetAlignVerticalCenter
      Category = 5
      ButtonStyle = bsChecked
      LargeImageIndex = 316
    end
    object dxBarButtonBottomAlign: TdxBarButton
      Action = dxSpreadSheetAlignVerticalBottom
      Category = 5
      ButtonStyle = bsChecked
      LargeImageIndex = 309
    end
    object dxBarButtonAlignTextLeft: TdxBarButton
      Action = dxSpreadSheetAlignHorizontalLeft
      Category = 5
      ButtonStyle = bsChecked
      LargeImageIndex = 315
    end
    object dxBarButtonAlignTextCenter: TdxBarButton
      Action = dxSpreadSheetAlignHorizontalCenter
      Category = 5
      ButtonStyle = bsChecked
      LargeImageIndex = 312
    end
    object dxBarButtonAlignTextRight: TdxBarButton
      Action = dxSpreadSheetAlignHorizontalRight
      Category = 5
      ButtonStyle = bsChecked
      LargeImageIndex = 319
    end
    object dxBarButtonDecreaseIndent: TdxBarButton
      Action = dxSpreadSheetTextIndentDecrease
      Category = 5
      LargeImageIndex = 334
    end
    object dxBarButtonIncreaseIndent: TdxBarButton
      Action = dxSpreadSheetTextIndentIncrease
      Category = 5
      LargeImageIndex = 336
    end
    object dxBarButtonWrapText: TdxBarButton
      Action = dxSpreadSheetTextWrap
      Caption = 'Testo a capo'
      Category = 5
      ButtonStyle = bsChecked
      LargeImageIndex = 183
    end
    object dxBarSubItem2: TdxBarSubItem
      Caption = 'Unisci'
      Category = 5
      Visible = ivAlways
      ImageIndex = 276
      LargeImageIndex = 276
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMergeandCenter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMergeAcross'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMergeCells'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUnmergeCells'
        end>
    end
    object dxBarLargeButtonMergeandCenter: TdxBarLargeButton
      Action = dxSpreadSheetMergeCellsAndCenter
      Category = 5
      SyncImageIndex = False
      ImageIndex = 276
    end
    object dxBarLargeButtonMergeAcross: TdxBarLargeButton
      Action = dxSpreadSheetMergeCellsAcross
      Category = 5
      SyncImageIndex = False
      ImageIndex = 274
    end
    object dxBarLargeButtonMergeCells: TdxBarLargeButton
      Action = dxSpreadSheetMergeCells
      Category = 5
      SyncImageIndex = False
      ImageIndex = 275
    end
    object dxBarLargeButtonUnmergeCells: TdxBarLargeButton
      Action = dxSpreadSheetUnmergeCells
      Category = 5
      SyncImageIndex = False
      ImageIndex = 288
    end
    object dxBarSubItem3: TdxBarSubItem
      Caption = 'Inserisci'
      Category = 6
      Visible = ivAlways
      ImageIndex = 98
      LargeImageIndex = 98
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertSheetRows'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertSheetColumns'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonInsertSheet'
        end>
    end
    object dxBarLargeButtonInsertSheetRows: TdxBarLargeButton
      Action = dxSpreadSheetInsertRows
      Category = 6
      SyncImageIndex = False
      ImageIndex = 108
    end
    object dxBarLargeButtonInsertSheetColumns: TdxBarLargeButton
      Action = dxSpreadSheetInsertColumns
      Category = 6
      SyncImageIndex = False
      ImageIndex = 100
    end
    object dxBarLargeButtonInsertSheet: TdxBarLargeButton
      Action = dxSpreadSheetInsertSheet
      Category = 6
      SyncImageIndex = False
      ImageIndex = 50
    end
    object dxBarSubItem4: TdxBarSubItem
      Caption = 'Elimina'
      Category = 6
      Visible = ivAlways
      ImageIndex = 70
      LargeImageIndex = 70
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteSheetRows'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteSheetColumns'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteSheet'
        end>
    end
    object dxBarLargeButtonDeleteSheetRows: TdxBarLargeButton
      Action = dxSpreadSheetDeleteRows
      Category = 6
      SyncImageIndex = False
      ImageIndex = 72
    end
    object dxBarLargeButtonDeleteSheetColumns: TdxBarLargeButton
      Action = dxSpreadSheetDeleteColumns
      Category = 6
      SyncImageIndex = False
      ImageIndex = 71
    end
    object dxBarLargeButtonDeleteSheet: TdxBarLargeButton
      Action = dxSpreadSheetDeleteSheet
      Category = 6
      SyncImageIndex = False
      ImageIndex = 66
    end
    object dxBarSubItem5: TdxBarSubItem
      Caption = 'Formato'
      Category = 6
      Visible = ivAlways
      ImageIndex = 24
      LargeImageIndex = 24
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonAutoFitRowHeight'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonAutoFitColumnWidth'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem6'
        end>
    end
    object dxBarLargeButtonAutoFitRowHeight: TdxBarLargeButton
      Action = dxSpreadSheetAutoFitRowHeight
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonAutoFitColumnWidth: TdxBarLargeButton
      Action = dxSpreadSheetAutoFitColumnWidth
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarSubItem6: TdxBarSubItem
      Caption = 'Hide and Unhide'
      Category = 6
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonHideRows'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonHideColumns'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonHideSheet'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonUnhideRows'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUnhideColumns'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUnhideSheet'
        end>
    end
    object dxBarLargeButtonHideRows: TdxBarLargeButton
      Action = dxSpreadSheetHideRows
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonHideColumns: TdxBarLargeButton
      Action = dxSpreadSheetHideColumns
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonHideSheet: TdxBarLargeButton
      Action = dxSpreadSheetHideSheet
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonUnhideRows: TdxBarLargeButton
      Action = dxSpreadSheetUnhideRows
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonUnhideColumns: TdxBarLargeButton
      Action = dxSpreadSheetUnhideColumns
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonUnhideSheet: TdxBarLargeButton
      Action = dxSpreadSheetUnhideSheet
      Category = 6
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarSubItem7: TdxBarSubItem
      Caption = 'Cancella'
      Category = 7
      Visible = ivAlways
      ImageIndex = 56
      LargeImageIndex = 56
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonClearAll'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonClearFormats'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonClearContents'
        end>
    end
    object dxBarLargeButtonClearAll: TdxBarLargeButton
      Action = dxSpreadSheetClearAll
      Category = 7
      SyncImageIndex = False
      ImageIndex = 56
    end
    object dxBarLargeButtonClearFormats: TdxBarLargeButton
      Action = dxSpreadSheetClearFormats
      Category = 7
      SyncImageIndex = False
      ImageIndex = 58
    end
    object dxBarLargeButtonClearContents: TdxBarLargeButton
      Action = dxSpreadSheetClearContents
      Category = 7
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonUndo: TdxBarLargeButton
      Action = dxSpreadSheetUndo
      Category = 7
      SyncImageIndex = False
      ImageIndex = 96
    end
    object dxBarLargeButtonRedo: TdxBarLargeButton
      Action = dxSpreadSheetRedo
      Category = 7
      SyncImageIndex = False
      ImageIndex = 87
    end
    object dxBarLargeButtonFindReplace: TdxBarLargeButton
      Action = dxSpreadSheetFindAndReplace
      Category = 7
      SyncImageIndex = False
      ImageIndex = 189
    end
    object dxBarLargeButtonPicture: TdxBarLargeButton
      Action = dxSpreadSheetInsertPicture
      Category = 8
      SyncImageIndex = False
      ImageIndex = 419
    end
    object dxBarLargeButtonHyperlink: TdxBarLargeButton
      Action = dxSpreadSheetShowHyperlinkEditor
      Category = 9
      SyncImageIndex = False
      ImageIndex = 525
    end
    object dxRibbonGalleryItemMargins: TdxRibbonGalleryItem
      Action = dxSpreadSheetPageMarginsGallery
      Category = 10
      ImageIndex = 294
      LargeImageIndex = 294
      GalleryOptions.ColumnCount = 1
      GalleryOptions.LongDescriptionDefaultRowCount = 3
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkCaptionAndDescription
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMorePageMargins'
        end>
      object dxRibbonGalleryItemMarginsGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemMarginsGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Normal'
          Description = 
            'Top:'#9'0,75 in    Bottom:'#9'0,75 in'#13#10'Left:'#9'0,70 in    Right:'#9'0,70 in' +
            #13#10'Header:'#9'0,30 in    Footer:'#9'0,30 in'
          ImageIndex = 296
          ActionIndex = 0
        end
        object dxRibbonGalleryItemMarginsGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Wide'
          Description = 
            'Top:'#9'1,00 in    Bottom:'#9'1,00 in'#13#10'Left:'#9'1,00 in    Right:'#9'1,00 in' +
            #13#10'Header:'#9'0,50 in    Footer:'#9'0,50 in'
          ImageIndex = 297
          ActionIndex = 1
        end
        object dxRibbonGalleryItemMarginsGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Narrow'
          Description = 
            'Top:'#9'0,75 in    Bottom:'#9'0,75 in'#13#10'Left:'#9'0,25 in    Right:'#9'0,25 in' +
            #13#10'Header:'#9'0,30 in    Footer:'#9'0,30 in'
          ImageIndex = 295
          ActionIndex = 2
        end
      end
    end
    object dxBarLargeButtonMorePageMargins: TdxBarLargeButton
      Action = dxSpreadSheetMorePageMargins
      Category = 10
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxRibbonGalleryItemOrientation: TdxRibbonGalleryItem
      Action = dxSpreadSheetPageOrientationGallery
      Category = 10
      ImageIndex = 298
      LargeImageIndex = 298
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextAlignVert = vaCenter
      ItemLinks = <>
      object dxRibbonGalleryItemOrientationGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemOrientationGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Portrait'
          ImageIndex = 300
          ActionIndex = 2
        end
        object dxRibbonGalleryItemOrientationGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Landscape'
          ImageIndex = 299
          ActionIndex = 1
        end
      end
    end
    object dxRibbonGalleryItemSize: TdxRibbonGalleryItem
      Action = dxSpreadSheetPaperSizeGallery
      Caption = 'Dimensioni'
      Category = 10
      ImageIndex = 306
      LargeImageIndex = 306
      GalleryOptions.ColumnCount = 1
      GalleryOptions.LongDescriptionDefaultRowCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkCaptionAndDescription
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMorePaperSizes'
        end>
      object dxRibbonGalleryItemSizeGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemSizeGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Letter'
          Description = '216,00 mm x 279,00 mm'
          ImageIndex = 304
          ActionIndex = 1
        end
        object dxRibbonGalleryItemSizeGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Tabloid'
          Description = '279,00 mm x 432,00 mm'
          ImageIndex = 305
          ActionIndex = 3
        end
        object dxRibbonGalleryItemSizeGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Legal'
          Description = '216,00 mm x 356,00 mm'
          ImageIndex = 303
          ActionIndex = 5
        end
        object dxRibbonGalleryItemSizeGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'Statement'
          Description = '140,00 mm x 216,00 mm'
          ImageIndex = 414
          ActionIndex = 6
        end
        object dxRibbonGalleryItemSizeGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'Executive'
          Description = '184,00 mm x 267,00 mm'
          ImageIndex = 302
          ActionIndex = 7
        end
        object dxRibbonGalleryItemSizeGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'A3'
          Description = '297,00 mm x 420,00 mm'
          ImageIndex = 303
          ActionIndex = 8
        end
        object dxRibbonGalleryItemSizeGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'A4'
          Description = '210,00 mm x 297,00 mm'
          ImageIndex = 303
          ActionIndex = 9
        end
        object dxRibbonGalleryItemSizeGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'A5'
          Description = '148,00 mm x 210,00 mm'
          ImageIndex = 303
          ActionIndex = 11
        end
        object dxRibbonGalleryItemSizeGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'B4 (JIS)'
          Description = '250,00 mm x 354,00 mm'
          ImageIndex = 414
          ActionIndex = 12
        end
        object dxRibbonGalleryItemSizeGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'B5 (JIS)'
          Description = '182,00 mm x 257,00 mm'
          ImageIndex = 414
          ActionIndex = 13
        end
      end
    end
    object dxBarLargeButtonMorePaperSizes: TdxBarLargeButton
      Action = dxSpreadSheetMorePaperSizes
      Category = 10
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarSubItem8: TdxBarSubItem
      Caption = 'Area di stampa'
      Category = 10
      Visible = ivAlways
      ImageIndex = 207
      LargeImageIndex = 207
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSetPrintArea'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonClearPrintArea'
        end>
    end
    object dxBarLargeButtonSetPrintArea: TdxBarLargeButton
      Action = dxSpreadSheetSetPrintArea
      Category = 10
      LargeImageIndex = 207
      SyncImageIndex = False
      ImageIndex = 207
    end
    object dxBarLargeButtonClearPrintArea: TdxBarLargeButton
      Action = dxSpreadSheetClearPrintArea
      Category = 10
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarSubItem9: TdxBarSubItem
      Caption = 'Interruzioni'
      Category = 10
      Visible = ivAlways
      ImageIndex = 105
      LargeImageIndex = 105
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertPageBreak'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonRemovePageBreak'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonResetAllPageBreaks'
        end>
    end
    object dxBarLargeButtonInsertPageBreak: TdxBarLargeButton
      Action = dxSpreadSheetInsertPageBreak
      Category = 10
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonRemovePageBreak: TdxBarLargeButton
      Action = dxSpreadSheetRemovePageBreak
      Category = 10
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonResetAllPageBreaks: TdxBarLargeButton
      Action = dxSpreadSheetResetAllPageBreaks
      Category = 10
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonPrintTitles: TdxBarLargeButton
      Action = dxSpreadSheetPrintTitles
      Category = 10
      LargeImageIndex = 291
      SyncImageIndex = False
      ImageIndex = 291
    end
    object dxRibbonGalleryItemAutoSum: TdxRibbonGalleryItem
      Action = dxSpreadSheetAutoSumGallery
      Category = 11
      ImageIndex = 398
      LargeImageIndex = 398
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemAutoSumGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemAutoSumGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Sum'
          Description = 'Sums all the specified numeric values.'
          ImageIndex = 398
          ActionIndex = 0
        end
        object dxRibbonGalleryItemAutoSumGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Average'
          Description = 'Calculates the average value of a numeric value series.'
          ImageIndex = 414
          ActionIndex = 1
        end
        object dxRibbonGalleryItemAutoSumGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Count Numbers'
          Description = 
            'Returns the number of cells that contain numbers or the total nu' +
            'mber of numeric values within the specified array.'
          ImageIndex = 414
          ActionIndex = 2
        end
        object dxRibbonGalleryItemAutoSumGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'Max'
          Description = 'Returns the maximum value in an array of numeric values.'
          ImageIndex = 414
          ActionIndex = 3
        end
        object dxRibbonGalleryItemAutoSumGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'Min'
          Description = 'Returns the minimum value in an array of numeric values.'
          ImageIndex = 414
          ActionIndex = 4
        end
      end
    end
    object dxRibbonGalleryItemFinancial: TdxRibbonGalleryItem
      Action = dxSpreadSheetFinancialFormulasGallery
      Caption = 'Finanze'
      Category = 11
      ImageIndex = 403
      LargeImageIndex = 403
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemFinancialGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemFinancialGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'FV'
          Description = 
            'Calculates the future value of an investment with periodic const' +
            'ant payments and a constant interest rate.'
          ActionIndex = 'FV'
        end
        object dxRibbonGalleryItemFinancialGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'IPMT'
          Description = 
            'Calculates the interest payment for a given period of an investm' +
            'ent, with periodic constant payments and a constant interest rat' +
            'e.'
          ActionIndex = 'IPMT'
        end
        object dxRibbonGalleryItemFinancialGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'NPER'
          Description = 
            'Returns the number of periods for an investment with periodic co' +
            'nstant payments and a constant interest rate.'
          ActionIndex = 'NPER'
        end
        object dxRibbonGalleryItemFinancialGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'NPV'
          Description = 
            'Calculates the net present value of an investment, based on a su' +
            'pplied discount rate, and a series of future payments and income' +
            '.'
          ActionIndex = 'NPV'
        end
        object dxRibbonGalleryItemFinancialGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'PMT'
          Description = 
            'Calculates the payments required to reduce a loan, from a suppli' +
            'ed present value to a specified future value.'
          ActionIndex = 'PMT'
        end
        object dxRibbonGalleryItemFinancialGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'PPMT'
          Description = 
            'Calculates the payment on the principal for a given investment, ' +
            'with periodic constant payments and a constant interest rate.'
          ActionIndex = 'PPMT'
        end
        object dxRibbonGalleryItemFinancialGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'PV'
          Description = 
            'Calculates the present value of an investment (i.e., the total a' +
            'mount that a series of future payments is worth now).'
          ActionIndex = 'PV'
        end
      end
    end
    object dxRibbonGalleryItemLogical: TdxRibbonGalleryItem
      Action = dxSpreadSheetLogicalFormulasGallery
      Caption = 'Logica'
      Category = 11
      ImageIndex = 405
      LargeImageIndex = 405
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemLogicalGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemLogicalGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'AND'
          Description = 'Performs the logical AND operation.'
          ActionIndex = 'AND'
        end
        object dxRibbonGalleryItemLogicalGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'FALSE'
          Description = 'Returns the logical value FALSE.'
          ActionIndex = 'FALSE'
        end
        object dxRibbonGalleryItemLogicalGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'IF'
          Description = 
            'Performs a logical test and returns either of the specified valu' +
            'es depending on the test'#8217's result.'
          ActionIndex = 'IF'
        end
        object dxRibbonGalleryItemLogicalGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'IFERROR'
          Description = 
            'Checks the specified formula expression for errors and returns t' +
            'he special value instead of an error code if an error occurs.'
          ActionIndex = 'IFERROR'
        end
        object dxRibbonGalleryItemLogicalGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'IFNA'
          Description = 
            'Checks if the specified formula expression returns the #N/A erro' +
            'r code and returns the special value instead.'
          ActionIndex = 'IFNA'
        end
        object dxRibbonGalleryItemLogicalGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'NOT'
          Description = 'Performs the logical negation operation.'
          ActionIndex = 'NOT'
        end
        object dxRibbonGalleryItemLogicalGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'OR'
          Description = 'Performs the logical OR operation.'
          ActionIndex = 'OR'
        end
        object dxRibbonGalleryItemLogicalGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'TRUE'
          Description = 'Returns the logical value TRUE.'
          ActionIndex = 'TRUE'
        end
        object dxRibbonGalleryItemLogicalGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'XOR'
          Description = 'Returns the logical exclusive OR of all specified values.'
          ActionIndex = 'XOR'
        end
      end
    end
    object dxRibbonGalleryItemText: TdxRibbonGalleryItem
      Action = dxSpreadSheetTextFormulasGallery
      Category = 11
      ImageIndex = 355
      LargeImageIndex = 355
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemTextGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemTextGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'CHAR'
          Description = 
            'Returns the character specified y a number. Use CHAR to translat' +
            'e code page numbers you might get from files on other types of c' +
            'omputers into characters.'
          ActionIndex = 'CHAR'
        end
        object dxRibbonGalleryItemTextGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'CLEAN'
          Description = 
            'Removes all non-printable characters from text. Use CLEAN on tex' +
            't imported from other applications that contains characters that' +
            ' may not print with your operating system.'
          ActionIndex = 'CLEAN'
        end
        object dxRibbonGalleryItemTextGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'CODE'
          Description = 
            'Returns a numeric code for the first character in a text string.' +
            ' The returned code corresponds to the character set used by your' +
            ' computer.'
          ActionIndex = 'CODE'
        end
        object dxRibbonGalleryItemTextGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'CONCATENATE'
          Description = 
            'Joins several text strings in one text string. An alternative to' +
            ' '#8220'&'#8221'.'
          ActionIndex = 'CONCATENATE'
        end
        object dxRibbonGalleryItemTextGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'DOLLAR'
          Description = 
            'Converts the number to text using currency format $#,##0.00_);($' +
            '#,##0.00), with the decimals rounded to the specified number of ' +
            'places.'
          ActionIndex = 'DOLLAR'
        end
        object dxRibbonGalleryItemTextGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'EXACT'
          Description = 
            'Compares two text strings and returns TRUE if they are exactly t' +
            'he same, FALSE otherwise. EXACT is case-sensitive but ignores fo' +
            'rmatting differences. Use EXACT to test text being entered into ' +
            'a document.'
          ActionIndex = 'EXACT'
        end
        object dxRibbonGalleryItemTextGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'FIND'
          Description = 
            'Locates one text string within a second text string, and returns' +
            ' the number of the starting position of the first text string fr' +
            'om the first character of the second text string. The single-byt' +
            'e version.'
          ActionIndex = 'FIND'
        end
        object dxRibbonGalleryItemTextGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'FIXED'
          Description = 
            'Rounds the first parameter to the number of decimals determined ' +
            'by the second parameter and returns it as a string. The third pa' +
            'rameter specifies whether to omit commas in the output string.'
          ActionIndex = 'FIXED'
        end
        object dxRibbonGalleryItemTextGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'LEFT'
          Description = 
            'Returns the first character or characters in a text string. The ' +
            'second parameter defines the number of characters to extract. Th' +
            'e single-byte version.'
          ActionIndex = 'LEFT'
        end
        object dxRibbonGalleryItemTextGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'LEN'
          Description = 
            'Returns the specified text string'#8217's length, in characters. The s' +
            'ingle-byte version.'
          ActionIndex = 'LEN'
        end
        object dxRibbonGalleryItemTextGroup1Item11: TdxRibbonGalleryGroupItem
          Caption = 'LOWER'
          Description = 'Converts a text string to lowercase.'
          ActionIndex = 'LOWER'
        end
        object dxRibbonGalleryItemTextGroup1Item12: TdxRibbonGalleryGroupItem
          Caption = 'MID'
          Description = 
            'Returns the substring of the specified text string. The single-b' +
            'yte version.'
          ActionIndex = 'MID'
        end
        object dxRibbonGalleryItemTextGroup1Item13: TdxRibbonGalleryGroupItem
          Caption = 'PROPER'
          Description = 
            'Capitalizes the first letter in a text string and any other lett' +
            'ers that follow any non-letter character. Converts all other let' +
            'ters to lowercase.'
          ActionIndex = 'PROPER'
        end
        object dxRibbonGalleryItemTextGroup1Item14: TdxRibbonGalleryGroupItem
          Caption = 'REPLACE'
          Description = 
            'Replaces a part of a text string with the specified text, based ' +
            'on the provided text size and character position. The single-byt' +
            'e version.'
          ActionIndex = 'REPLACE'
        end
        object dxRibbonGalleryItemTextGroup1Item15: TdxRibbonGalleryGroupItem
          Caption = 'REPT'
          Description = 'Repeats the text string a specific number of times.'
          ActionIndex = 'REPT'
        end
        object dxRibbonGalleryItemTextGroup1Item16: TdxRibbonGalleryGroupItem
          Caption = 'RIGHT'
          Description = 
            'Returns one or more last characters in a text string. The single' +
            '-byte version.'
          ActionIndex = 'RIGHT'
        end
        object dxRibbonGalleryItemTextGroup1Item17: TdxRibbonGalleryGroupItem
          Caption = 'SEARCH'
          Description = 
            'Searches one text string within another. The single-byte version' +
            '.'
          ActionIndex = 'SEARCH'
        end
        object dxRibbonGalleryItemTextGroup1Item18: TdxRibbonGalleryGroupItem
          Caption = 'SUBSTITUTE'
          Description = 'Substitutes a specific text with another text in a string.'
          ActionIndex = 'SUBSTITUTE'
        end
        object dxRibbonGalleryItemTextGroup1Item19: TdxRibbonGalleryGroupItem
          Caption = 'T'
          Description = 'Returns text to which the specified value refers.'
          ActionIndex = 'T'
        end
        object dxRibbonGalleryItemTextGroup1Item20: TdxRibbonGalleryGroupItem
          Caption = 'TEXT'
          Description = 'Formats a specific value as text.'
          ActionIndex = 'TEXT'
        end
        object dxRibbonGalleryItemTextGroup1Item21: TdxRibbonGalleryGroupItem
          Caption = 'TRIM'
          Description = 
            'Removes all spaces from text, except for single spaces between i' +
            'ndividual words.'
          ActionIndex = 'TRIM'
        end
        object dxRibbonGalleryItemTextGroup1Item22: TdxRibbonGalleryGroupItem
          Caption = 'UPPER'
          Description = 'Converts a text string to uppercase.'
          ActionIndex = 'UPPER'
        end
        object dxRibbonGalleryItemTextGroup1Item23: TdxRibbonGalleryGroupItem
          Caption = 'VALUE'
          Description = 'Converts a text string to a numeric value.'
          ActionIndex = 'VALUE'
        end
      end
    end
    object dxRibbonGalleryItemDateTime: TdxRibbonGalleryItem
      Action = dxSpreadSheetDateAndTimeFormulasGallery
      Caption = 'Date e ora'
      Category = 11
      ImageIndex = 476
      LargeImageIndex = 476
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemDateTimeGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemDateTimeGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'DATE'
          Description = 
            'Calculates the serial number corresponding to the specified date' +
            '.'
          ActionIndex = 'DATE'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'DATEVALUE'
          Description = 
            'Converts a date specified as a text string to the corresponding ' +
            'serial number.'
          ActionIndex = 'DATEVALUE'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'DAY'
          Description = 'Converts a serial number to the corresponding date (day).'
          ActionIndex = 'DAY'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'DAYS'
          Description = 'Returns the number of days between two specified dates.'
          ActionIndex = 'DAYS'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'DAYS360'
          Description = 
            'Returns the number of days between two specified dates based on ' +
            'a 360-day year (that includes twelve 30-day months), which is us' +
            'ed in some accounting calculations.'
          ActionIndex = 'DAYS360'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'EDATE'
          Description = 
            'Returns the serial number of the date that is the indicated numb' +
            'er of months before or after the start date.'
          ActionIndex = 'EDATE'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'EOMONTH'
          Description = 
            'Returns the serial number of the last day of the month before or' +
            ' after a specified number of months.'
          ActionIndex = 'EOMONTH'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'HOUR'
          Description = 'Converts a serial number to the corresponding hour.'
          ActionIndex = 'HOUR'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'ISOWEEKNUM'
          Description = 
            'Returns the ISO number of the week to which the specified date b' +
            'elongs.'
          ActionIndex = 'ISOWEEKNUM'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'MINUTE'
          Description = 'Converts a serial number to the corresponding minute.'
          ActionIndex = 'MINUTE'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item11: TdxRibbonGalleryGroupItem
          Caption = 'MONTH'
          Description = 'Converts a serial number to the corresponding month.'
          ActionIndex = 'MONTH'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item12: TdxRibbonGalleryGroupItem
          Caption = 'NETWORKDAYS'
          Description = 
            'This function is useful for calculating employee benefits that a' +
            'ccrue based on the number of days worked under specific terms.'
          ActionIndex = 'NETWORKDAYS'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item13: TdxRibbonGalleryGroupItem
          Caption = 'NETWORKDAYS.INTL'
          Description = 
            'Returns the number of whole workdays between two specified dates' +
            '.'
          ActionIndex = 'NETWORKDAYS.INTL'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item14: TdxRibbonGalleryGroupItem
          Caption = 'NOW'
          Description = 'Returns the current time as a date/time value.'
          ActionIndex = 'NOW'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item15: TdxRibbonGalleryGroupItem
          Caption = 'SECOND'
          Description = 'Converts a serial number to the corresponding second.'
          ActionIndex = 'SECOND'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item16: TdxRibbonGalleryGroupItem
          Caption = 'TIME'
          Description = 'Converts the specified time to the corresponding serial number.'
          ActionIndex = 'TIME'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item17: TdxRibbonGalleryGroupItem
          Caption = 'TIMEVALUE'
          Description = 'Converts a text time representation into a date/time value.'
          ActionIndex = 'TIMEVALUE'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item18: TdxRibbonGalleryGroupItem
          Caption = 'TODAY'
          Description = 'Returns the serial number corresponding to the current date.'
          ActionIndex = 'TODAY'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item19: TdxRibbonGalleryGroupItem
          Caption = 'WEEKDAY'
          Description = 
            'Returns the day of the week corresponding to the specified date ' +
            'value.'
          ActionIndex = 'WEEKDAY'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item20: TdxRibbonGalleryGroupItem
          Caption = 'WEEKNUM'
          Description = 'Returns the week number corresponding to the specified date.'
          ActionIndex = 'WEEKNUM'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item21: TdxRibbonGalleryGroupItem
          Caption = 'WORKDAY'
          Description = 
            'Returns the workday separated from the initial date by the speci' +
            'fied number of workdays. The returned day precedes or follows th' +
            'e initial date, depending on the day count'#8217's sign.'
          ActionIndex = 'WORKDAY'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item22: TdxRibbonGalleryGroupItem
          Caption = 'WORKDAY.INTL'
          Description = 
            'Returns the serial number of the date before or after the specif' +
            'ied number of workdays, taking a custom set of holidays into acc' +
            'ount.'
          ActionIndex = 'WORKDAY.INTL'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item23: TdxRibbonGalleryGroupItem
          Caption = 'YEAR'
          Description = 'Returns the serial number corresponding to the specified year.'
          ActionIndex = 'YEAR'
        end
        object dxRibbonGalleryItemDateTimeGroup1Item24: TdxRibbonGalleryGroupItem
          Caption = 'YEARFRAC'
          Description = 
            'Calculates the fraction of the year within the range between two' +
            ' specified dates.'
          ActionIndex = 'YEARFRAC'
        end
      end
    end
    object dxRibbonGalleryItemLookupReference: TdxRibbonGalleryItem
      Action = dxSpreadSheetLookupAndReferenceFormulasGallery
      Caption = 'Ricerca e riferimento'
      Category = 11
      ImageIndex = 406
      LargeImageIndex = 406
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemLookupReferenceGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemLookupReferenceGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'ADDRESS'
          Description = 'Returns a reference as text to a single cell in a worksheet.'
          ActionIndex = 'ADDRESS'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'AREAS'
          Description = 'Returns the number of areas in a reference.'
          ActionIndex = 'AREAS'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'CHOOSE'
          Description = 
            'Returns a value from the list of value parameters. You can use t' +
            'his function to select one of the specified values based on the ' +
            'index number.'
          ActionIndex = 'CHOOSE'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'COLUMN'
          Description = 'Returns the column number of a reference.'
          ActionIndex = 'COLUMN'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'COLUMNS'
          Description = 'Returns the number of columns in a reference.'
          ActionIndex = 'COLUMNS'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'FORMULATEXT'
          Description = 
            'Returns a text representation of the specified formula expressio' +
            'n.'
          ActionIndex = 'FORMULATEXT'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'HLOOKUP'
          Description = 
            'Looks up a value in the first table row, and returns a value in ' +
            'the same column from another row.'
          ActionIndex = 'HLOOKUP'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'INDEX'
          Description = 
            'Returns the value of an element in a table or an array, selected' +
            ' by the row and column number indexes.'
          ActionIndex = 'INDEX'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'INDIRECT'
          Description = 'Returns the reference specified by a text string.'
          ActionIndex = 'INDIRECT'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'LOOKUP'
          Description = 
            'Returns a value from a cell in a position found by lookup in a s' +
            'earch table.'
          ActionIndex = 'LOOKUP'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item11: TdxRibbonGalleryGroupItem
          Caption = 'MATCH'
          Description = 
            'Searches for a specified item in a range of cells and returns th' +
            'e relative position of that item in the range.'
          ActionIndex = 'MATCH'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item12: TdxRibbonGalleryGroupItem
          Caption = 'OFFSET'
          Description = 
            'Returns a reference to a range that is located a specified numbe' +
            'r of rows and columns away from a cell or cell range.'
          ActionIndex = 'OFFSET'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item13: TdxRibbonGalleryGroupItem
          Caption = 'ROW'
          Description = 'Returns the row number of a reference.'
          ActionIndex = 'ROW'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item14: TdxRibbonGalleryGroupItem
          Caption = 'ROWS'
          Description = 'Returns the number of rows in a reference or array.'
          ActionIndex = 'ROWS'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item15: TdxRibbonGalleryGroupItem
          Caption = 'TRANSPOSE'
          Description = 
            'Transforms a horizontal range of cells into a vertical range, an' +
            'd vice versa.'
          ActionIndex = 'TRANSPOSE'
        end
        object dxRibbonGalleryItemLookupReferenceGroup1Item16: TdxRibbonGalleryGroupItem
          Caption = 'VLOOKUP'
          Description = 
            'Looks up a value in the first column of a table, and returns a v' +
            'alue in the same row from another column.'
          ActionIndex = 'VLOOKUP'
        end
      end
    end
    object dxRibbonGalleryItemMathTrig: TdxRibbonGalleryItem
      Action = dxSpreadSheetMathAndTrigFormulasGallery
      Caption = 'Matematica e trig.'
      Category = 11
      ImageIndex = 544
      LargeImageIndex = 544
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrHeight
      ItemLinks = <>
      object dxRibbonGalleryItemMathTrigGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemMathTrigGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'ABS'
          Description = 'Returns the absolute value.'
          ActionIndex = 'ABS'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'ACOS'
          Description = 'Returns the arccosine.'
          ActionIndex = 'ACOS'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'ACOSH'
          Description = 'Returns the inverse hyperbolic cosine.'
          ActionIndex = 'ACOSH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'ACOT'
          Description = 'Returns the principal value of the arccotangent.'
          ActionIndex = 'ACOT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'ACOTH'
          Description = 'Returns the inverse hyperbolic cotangent.'
          ActionIndex = 'ACOTH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'ASIN'
          Description = 'Returns the arcsine.'
          ActionIndex = 'ASIN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'ASINH'
          Description = 'Returns the inverse hyperbolic sine.'
          ActionIndex = 'ASINH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'ATAN'
          Description = 'Returns the arctangent.'
          ActionIndex = 'ATAN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'ATAN2'
          Description = 'Returns the arctangent using the specified X and Y coordinates.'
          ActionIndex = 'ATAN2'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'ATANH'
          Description = 'Returns the inverse hyperbolic tangent.'
          ActionIndex = 'ATANH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item11: TdxRibbonGalleryGroupItem
          Caption = 'BASE'
          Description = 
            'Converts a number into a text representation with the specified ' +
            'base (radix).'
          ActionIndex = 'BASE'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item12: TdxRibbonGalleryGroupItem
          Caption = 'CEILING'
          Description = 
            'Rounds the value up to the nearest multiple based on the specifi' +
            'ed significance.'
          ActionIndex = 'CEILING'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item13: TdxRibbonGalleryGroupItem
          Caption = 'CEILING.MATH'
          Description = 
            'Rounds a number up to the nearest integer or to the nearest mult' +
            'iple of significance.'
          ActionIndex = 'CEILING.MATH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item14: TdxRibbonGalleryGroupItem
          Caption = 'CEILING.PRECISE'
          Description = 
            'Returns a number that is rounded up to the nearest integer or to' +
            ' the nearest multiple of significance.'
          ActionIndex = 'CEILING.PRECISE'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item15: TdxRibbonGalleryGroupItem
          Caption = 'COMBIN'
          Description = 
            'Returns the number of combinations for the specified number of i' +
            'tems.'
          ActionIndex = 'COMBIN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item16: TdxRibbonGalleryGroupItem
          Caption = 'COMBINA'
          Description = 
            'Returns the number of combinations for the specified number of i' +
            'tems (including repetitions).'
          ActionIndex = 'COMBINA'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item17: TdxRibbonGalleryGroupItem
          Caption = 'COS'
          Description = 'Returns the cosine.'
          ActionIndex = 'COS'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item18: TdxRibbonGalleryGroupItem
          Caption = 'COSH'
          Description = 'Returns the hyperbolic cosine.'
          ActionIndex = 'COSH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item19: TdxRibbonGalleryGroupItem
          Caption = 'COT'
          Description = 'Returns the cotangent.'
          ActionIndex = 'COT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item20: TdxRibbonGalleryGroupItem
          Caption = 'COTH'
          Description = 'Returns the hyperbolic cotangent.'
          ActionIndex = 'COTH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item21: TdxRibbonGalleryGroupItem
          Caption = 'CSC'
          Description = 'Returns the cosecant.'
          ActionIndex = 'CSC'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item22: TdxRibbonGalleryGroupItem
          Caption = 'CSCH'
          Description = 'Returns the hyperbolic cosecant.'
          ActionIndex = 'CSCH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item23: TdxRibbonGalleryGroupItem
          Caption = 'DECIMAL'
          Description = 
            'Converts a text representation of a number into a number using t' +
            'he specified base (radix).'
          ActionIndex = 'DECIMAL'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item24: TdxRibbonGalleryGroupItem
          Caption = 'DEGREES'
          Description = 'Converts radians to degrees.'
          ActionIndex = 'DEGREES'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item25: TdxRibbonGalleryGroupItem
          Caption = 'EVEN'
          Description = 'Rounds the specified value up to the nearest even integer.'
          ActionIndex = 'EVEN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item26: TdxRibbonGalleryGroupItem
          Caption = 'EXP'
          Description = 'Returns the exponent of the specified value.'
          ActionIndex = 'EXP'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item27: TdxRibbonGalleryGroupItem
          Caption = 'FACT'
          Description = 'Returns the factorial.'
          ActionIndex = 'FACT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item28: TdxRibbonGalleryGroupItem
          Caption = 'FACTDOUBLE'
          Description = 'Returns the double factorial.'
          ActionIndex = 'FACTDOUBLE'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item29: TdxRibbonGalleryGroupItem
          Caption = 'FLOOR'
          Description = 
            'Rounds the value down to the nearest multiple of the specified s' +
            'ignificance.'
          ActionIndex = 'FLOOR'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item30: TdxRibbonGalleryGroupItem
          Caption = 'FLOOR.MATH'
          Description = 
            'Rounds the number down to the nearest integer or to the nearest ' +
            'multiple of significance.'
          ActionIndex = 'FLOOR.MATH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item31: TdxRibbonGalleryGroupItem
          Caption = 'FLOOR.PRECISE'
          Description = 
            'Returns a number that is rounded up to the nearest integer or to' +
            ' the nearest multiple of significance.'
          ActionIndex = 'FLOOR.PRECISE'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item32: TdxRibbonGalleryGroupItem
          Caption = 'INT'
          Description = 'Rounds the value down to the nearest integer.'
          ActionIndex = 'INT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item33: TdxRibbonGalleryGroupItem
          Caption = 'ISO.CEILING'
          Description = 
            'Rounds the value up to the nearest integer or to the nearest mul' +
            'tiple of significance. The function always rounds the specified ' +
            'numeric value up.'
          ActionIndex = 'ISO.CEILING'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item34: TdxRibbonGalleryGroupItem
          Caption = 'LN'
          Description = 'Returns the natural logarithm.'
          ActionIndex = 'LN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item35: TdxRibbonGalleryGroupItem
          Caption = 'LOG'
          Description = 'Returns the value'#8217's logarithm to the specified base.'
          ActionIndex = 'LOG'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item36: TdxRibbonGalleryGroupItem
          Caption = 'LOG10'
          Description = 'Returns the value'#8217's base-10 logarithm.'
          ActionIndex = 'LOG10'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item37: TdxRibbonGalleryGroupItem
          Caption = 'MMULT'
          Description = 'Returns the matrix product of two arrays.'
          ActionIndex = 'MMULT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item38: TdxRibbonGalleryGroupItem
          Caption = 'MOD'
          Description = 
            'Returns the remainder after one specified number is divided by t' +
            'he other.'
          ActionIndex = 'MOD'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item39: TdxRibbonGalleryGroupItem
          Caption = 'MROUND'
          Description = 'Rounds a numeric value to the specified multiple.'
          ActionIndex = 'MROUND'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item40: TdxRibbonGalleryGroupItem
          Caption = 'ODD'
          Description = 'Rounds the numeric value up to the nearest integer.'
          ActionIndex = 'ODD'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item41: TdxRibbonGalleryGroupItem
          Caption = 'PI'
          Description = 'Returns the value of Pi.'
          ActionIndex = 'PI'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item42: TdxRibbonGalleryGroupItem
          Caption = 'POWER'
          Description = 'Raises the numeric value to the specified power.'
          ActionIndex = 'POWER'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item43: TdxRibbonGalleryGroupItem
          Caption = 'PRODUCT'
          Description = 'Multiplies all the parameter values and returns the product.'
          ActionIndex = 'PRODUCT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item44: TdxRibbonGalleryGroupItem
          Caption = 'QUOTIENT'
          Description = 
            'Discards the remainder of a division and returns its integer por' +
            'tion.'
          ActionIndex = 'QUOTIENT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item45: TdxRibbonGalleryGroupItem
          Caption = 'RADIANS'
          Description = 'Converts degrees to radians.'
          ActionIndex = 'RADIANS'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item46: TdxRibbonGalleryGroupItem
          Caption = 'RAND'
          Description = 
            'Returns a random number within the range between 0 and 1, inclus' +
            'ive.'
          ActionIndex = 'RAND'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item47: TdxRibbonGalleryGroupItem
          Caption = 'RANDBETWEEN'
          Description = 'Returns a random integer within the specified range.'
          ActionIndex = 'RANDBETWEEN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item48: TdxRibbonGalleryGroupItem
          Caption = 'ROUND'
          Description = 'Rounds a numeric value to the specified number of digits.'
          ActionIndex = 'ROUND'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item49: TdxRibbonGalleryGroupItem
          Caption = 'ROUNDDOWN'
          Description = 'Rounds a numeric value towards zero.'
          ActionIndex = 'ROUNDDOWN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item50: TdxRibbonGalleryGroupItem
          Caption = 'ROUNDUP'
          Description = 'Rounds a numeric value towards infinity.'
          ActionIndex = 'ROUNDUP'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item51: TdxRibbonGalleryGroupItem
          Caption = 'SEC'
          Description = 'Returns the secant.'
          ActionIndex = 'SEC'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item52: TdxRibbonGalleryGroupItem
          Caption = 'SECH'
          Description = 'Returns the hyperbolic secant.'
          ActionIndex = 'SECH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item53: TdxRibbonGalleryGroupItem
          Caption = 'SIGN'
          Description = 'Returns the specified number'#8217's sign.'
          ActionIndex = 'SIGN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item54: TdxRibbonGalleryGroupItem
          Caption = 'SIN'
          Description = 'Returns the sine.'
          ActionIndex = 'SIN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item55: TdxRibbonGalleryGroupItem
          Caption = 'SINH'
          Description = 'Returns the hyperbolic sine.'
          ActionIndex = 'SINH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item56: TdxRibbonGalleryGroupItem
          Caption = 'SQRT'
          Description = 'Returns the square root.'
          ActionIndex = 'SQRT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item57: TdxRibbonGalleryGroupItem
          Caption = 'SQRTPI'
          Description = 'Returns the square root of Pi multiplied by the specified value.'
          ActionIndex = 'SQRTPI'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item58: TdxRibbonGalleryGroupItem
          Caption = 'SUBTOTAL'
          Description = 'Returns a subtotal.'
          ActionIndex = 'SUBTOTAL'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item59: TdxRibbonGalleryGroupItem
          Caption = 'SUM'
          Description = 'Sums all the specified numeric values.'
          ActionIndex = 'SUM'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item60: TdxRibbonGalleryGroupItem
          Caption = 'SUMIF'
          Description = 
            'Sums the numeric values within an array that meet a specific cri' +
            'terion.'
          ActionIndex = 'SUMIF'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item61: TdxRibbonGalleryGroupItem
          Caption = 'SUMIFS'
          Description = 
            'Sums the numeric values within an array that meet multiple crite' +
            'ria.'
          ActionIndex = 'SUMIFS'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item62: TdxRibbonGalleryGroupItem
          Caption = 'SUMPRODUCT'
          Description = 
            'Multiplies the corresponding numeric values in all specified arr' +
            'ays and sums the products.'
          ActionIndex = 'SUMPRODUCT'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item63: TdxRibbonGalleryGroupItem
          Caption = 'SUMSQ'
          Description = 'Sums the squares of values in a series of numbers.'
          ActionIndex = 'SUMSQ'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item64: TdxRibbonGalleryGroupItem
          Caption = 'SUMX2MY2'
          Description = 
            'Sums the differences of the corresponding squared values in two ' +
            'specified arrays.'
          ActionIndex = 'SUMX2MY2'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item65: TdxRibbonGalleryGroupItem
          Caption = 'SUMX2PY2'
          Description = 
            'Sums the sums of the corresponding squared values in two specifi' +
            'ed arrays.'
          ActionIndex = 'SUMX2PY2'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item66: TdxRibbonGalleryGroupItem
          Caption = 'SUMXMY2'
          Description = 
            'Sums the squares of differences of the corresponding values in t' +
            'wo specified arrays.'
          ActionIndex = 'SUMXMY2'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item67: TdxRibbonGalleryGroupItem
          Caption = 'TAN'
          Description = 'Returns the tangent.'
          ActionIndex = 'TAN'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item68: TdxRibbonGalleryGroupItem
          Caption = 'TANH'
          Description = 'Returns the hyperbolic tangent.'
          ActionIndex = 'TANH'
        end
        object dxRibbonGalleryItemMathTrigGroup1Item69: TdxRibbonGalleryGroupItem
          Caption = 'TRUNC'
          Description = 'Truncates a fractional part of the specified numeric value.'
          ActionIndex = 'TRUNC'
        end
      end
    end
    object dxBarSubItem10: TdxBarSubItem
      Caption = 'Altre funzioni'
      Category = 11
      Visible = ivAlways
      ImageIndex = 408
      LargeImageIndex = 408
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemStatistical'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemInformation'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemCompatibility'
        end>
    end
    object dxRibbonGalleryItemStatistical: TdxRibbonGalleryItem
      Action = dxSpreadSheetStatisticalFormulasGallery
      Category = 11
      ImageIndex = 410
      LargeImageIndex = 410
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrHeight
      ItemLinks = <>
      object dxRibbonGalleryItemStatisticalGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemStatisticalGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'AVEDEV'
          Description = 
            'Returns the average of the absolute deviations of a numeric valu' +
            'e series from their mean. The calculated value is a measure of t' +
            'he data set variability.'
          ActionIndex = 'AVEDEV'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'AVERAGE'
          Description = 'Calculates the average value of a numeric value series.'
          ActionIndex = 'AVERAGE'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'AVERAGEA'
          Description = 
            'Calculates the average value of numeric values in all non-empty ' +
            'cells.'
          ActionIndex = 'AVERAGEA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'AVERAGEIF'
          Description = 
            'Returns the average (that is, the arithmetic mean) of all cells ' +
            'within the cell range that meet a specific criterion.'
          ActionIndex = 'AVERAGEIF'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'AVERAGEIFS'
          Description = 
            'Returns the average (that is, the arithmetic mean) of all cells ' +
            'that meet multiple criteria.'
          ActionIndex = 'AVERAGEIFS'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'BETA.DIST'
          Description = 
            'Returns the cumulative beta probability density distribution. Th' +
            'e beta distribution is useful to study variation of a specific i' +
            'ndicator (as a percentage) across samples.'
          ActionIndex = 'BETA.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'BETA.INV'
          Description = 
            'Returns the inverse of the cumulative beta probability density f' +
            'unction for the specified beta distribution probability.'
          ActionIndex = 'BETA.INV'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'BINOM.DIST'
          Description = 
            'Returns the individual term binomial distribution probability. Y' +
            'ou can use this function to evaluate a fixed number of independe' +
            'nt trials that can result only in success or failure, provided t' +
            'hat the probability of success does not change throughout the ex' +
            'periment.'
          ActionIndex = 'BINOM.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'BINOM.DIST.RANGE'
          Description = 
            'Returns the probability of a trial'#8217's result by using a binomial ' +
            'distribution.'
          ActionIndex = 'BINOM.DIST.RANGE'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'CHISQ.DIST'
          Description = 
            'Returns the chi-squared distribution which is commonly used to s' +
            'tudy variation in the percentage of a specific indicator across ' +
            'samples.'
          ActionIndex = 'CHISQ.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item11: TdxRibbonGalleryGroupItem
          Caption = 'CHISQ.DIST.RT'
          Description = 
            'Returns the right-tailed probability of the chi-squared distribu' +
            'tion. You can use this function to calculate the variation of a ' +
            'certain indicator across the experimental data.'
          ActionIndex = 'CHISQ.DIST.RT'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item12: TdxRibbonGalleryGroupItem
          Caption = 'CHISQ.INV'
          Description = 
            'Returns the inverse of the left-tailed probability of the chi-sq' +
            'uared distribution.'
          ActionIndex = 'CHISQ.INV'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item13: TdxRibbonGalleryGroupItem
          Caption = 'CHISQ.INV.RT'
          Description = 
            'Iteratively calculates the inverse of the right-tailed probabili' +
            'ty of the chi-squared distribution.'
          ActionIndex = 'CHISQ.INV.RT'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item14: TdxRibbonGalleryGroupItem
          Caption = 'CORREL'
          Description = 
            'Returns the correlation coefficient between two specified arrays' +
            ' of numeric values. Use this function to determine the relations' +
            'hip between data sets.'
          ActionIndex = 'CORREL'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item15: TdxRibbonGalleryGroupItem
          Caption = 'COUNT'
          Description = 
            'Returns the number of cells that contain numbers or the total nu' +
            'mber of numeric values within the specified array.'
          ActionIndex = 'COUNT'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item16: TdxRibbonGalleryGroupItem
          Caption = 'COUNTA'
          Description = 
            'Returns the total number of non-empty cells within the specified' +
            ' cell range.'
          ActionIndex = 'COUNTA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item17: TdxRibbonGalleryGroupItem
          Caption = 'COUNTBLANK'
          Description = 
            'Returns the total number of blank cells within the specified cel' +
            'l range.'
          ActionIndex = 'COUNTBLANK'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item18: TdxRibbonGalleryGroupItem
          Caption = 'COUNTIF'
          Description = 
            'Returns the number of cells within the specified range that meet' +
            ' a specific criterion.'
          ActionIndex = 'COUNTIF'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item19: TdxRibbonGalleryGroupItem
          Caption = 'COUNTIFS'
          Description = 
            'Returns the number of cells within the specified range that meet' +
            ' multiple criteria.'
          ActionIndex = 'COUNTIFS'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item20: TdxRibbonGalleryGroupItem
          Caption = 'COVARIANCE.P'
          Description = 
            'Calculates the population average of the products of deviations ' +
            '(that is, population covariance) for each pair of values in the ' +
            'specified series of numeric values.'
          ActionIndex = 'COVARIANCE.P'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item21: TdxRibbonGalleryGroupItem
          Caption = 'COVARIANCE.S'
          Description = 
            'Calculates the sample average of the products of deviations (tha' +
            't is, sample covariance) for each pair of values in the specifie' +
            'd series of numeric values.'
          ActionIndex = 'COVARIANCE.S'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item22: TdxRibbonGalleryGroupItem
          Caption = 'DEVSQ'
          Description = 
            'Returns the sum of squares of deviations of a numbers in an arra' +
            'y from their sample mean.'
          ActionIndex = 'DEVSQ'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item23: TdxRibbonGalleryGroupItem
          Caption = 'EXPON.DIST'
          Description = 
            'Returns the exponential distribution. This function is useful if' +
            ' you need to evaluate the process duration probabilities.'
          ActionIndex = 'EXPON.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item24: TdxRibbonGalleryGroupItem
          Caption = 'FORECAST'
          Description = 
            'Forecasts a future value in a linear trend by using existing pai' +
            'rs of X and Y values.'
          ActionIndex = 'FORECAST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item25: TdxRibbonGalleryGroupItem
          Caption = 'GAMMA'
          Description = 'Returns the Gamma function value.'
          ActionIndex = 'GAMMA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item26: TdxRibbonGalleryGroupItem
          Caption = 'GAMMA.DIST'
          Description = 
            'Returns the gamma distribution. You can use this function to stu' +
            'dy a series of numbers that may have a skewed distribution. The ' +
            'gamma distribution is commonly used in queuing analysis.'
          ActionIndex = 'GAMMA.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item27: TdxRibbonGalleryGroupItem
          Caption = 'GAMMA.INV'
          Description = 
            'Iteratively calculates the inverse of the gamma cumulative distr' +
            'ibution. The gamma distribution is useful to study values that h' +
            'ave a skewed distribution.'
          ActionIndex = 'GAMMA.INV'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item28: TdxRibbonGalleryGroupItem
          Caption = 'GAMMALN'
          Description = 'Returns the natural logarithm of the Gamma function.'
          ActionIndex = 'GAMMALN'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item29: TdxRibbonGalleryGroupItem
          Caption = 'GAMMALN.PRECISE'
          Description = 
            'Returns the natural logarithm of the Gamma function (a high prec' +
            'ision version).'
          ActionIndex = 'GAMMALN.PRECISE'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item30: TdxRibbonGalleryGroupItem
          Caption = 'GAUSS'
          Description = 
            'Calculates the probability that a member of a standard normal po' +
            'pulation is between the mean and Z standard deviation from the m' +
            'ean.'
          ActionIndex = 'GAUSS'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item31: TdxRibbonGalleryGroupItem
          Caption = 'GEOMEAN'
          Description = 
            'Returns the geometric mean of an array of positive numeric value' +
            's.'
          ActionIndex = 'GEOMEAN'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item32: TdxRibbonGalleryGroupItem
          Caption = 'HYPGEOM.DIST'
          Description = 
            'Returns the hypergeometric distribution, that is, the probabilit' +
            'y of a specified number of sample successes at a specific sample' +
            ' size, number of population successes, and population size.'
          ActionIndex = 'HYPGEOM.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item33: TdxRibbonGalleryGroupItem
          Caption = 'INTERCEPT'
          Description = 
            'Calculates the point at which a line will intersect the Y-axis b' +
            'y using the known X and Y values. The intercept point is based o' +
            'n a best-fit regression line plotted through the known pairs of ' +
            'numeric values.'
          ActionIndex = 'INTERCEPT'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item34: TdxRibbonGalleryGroupItem
          Caption = 'LARGE'
          Description = 'Returns the K-th largest value in a series of numeric values.'
          ActionIndex = 'LARGE'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item35: TdxRibbonGalleryGroupItem
          Caption = 'MAX'
          Description = 'Returns the maximum value in an array of numeric values.'
          ActionIndex = 'MAX'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item36: TdxRibbonGalleryGroupItem
          Caption = 'MAXA'
          Description = 
            'Returns the maximum value in an array, including numeric values,' +
            ' text, and logical values.'
          ActionIndex = 'MAXA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item37: TdxRibbonGalleryGroupItem
          Caption = 'MEDIAN'
          Description = 'Returns the median of a series of numeric values.'
          ActionIndex = 'MEDIAN'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item38: TdxRibbonGalleryGroupItem
          Caption = 'MIN'
          Description = 'Returns the minimum value in an array of numeric values.'
          ActionIndex = 'MIN'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item39: TdxRibbonGalleryGroupItem
          Caption = 'MINA'
          Description = 
            'Returns the minimum value in an array, including numeric values,' +
            ' text, and logical values.'
          ActionIndex = 'MINA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item40: TdxRibbonGalleryGroupItem
          Caption = 'MODE.MULT'
          Description = 
            'Returns a vertical array populated with the most frequently occu' +
            'rring (repetitive) values in an array of numeric values.'
          ActionIndex = 'MODE.MULT'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item41: TdxRibbonGalleryGroupItem
          Caption = 'MODE.SNGL'
          Description = 
            'Calculates the mode of a group of numbers, that is, returns the ' +
            'most frequently occurring (repetitive) value among all specified' +
            ' numeric values.'
          ActionIndex = 'MODE.SNGL'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item42: TdxRibbonGalleryGroupItem
          Caption = 'NORM.DIST'
          Description = 
            'Returns the normal distribution for the specified mean and stand' +
            'ard deviation. This function is widely used in statistics, inclu' +
            'ding hypothesis testing.'
          ActionIndex = 'NORM.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item43: TdxRibbonGalleryGroupItem
          Caption = 'NORM.INV'
          Description = 
            'Iteratively calculates the inverse of the normal distribution fo' +
            'r the specified mean and standard deviation.'
          ActionIndex = 'NORM.INV'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item44: TdxRibbonGalleryGroupItem
          Caption = 'NORM.S.DIST'
          Description = 
            'Returns the standard normal cumulative distribution function. Th' +
            'e standard distribution'#8217's arithmetic mean and standard deviation' +
            ' are 0 and 1, respectively.'
          ActionIndex = 'NORM.S.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item45: TdxRibbonGalleryGroupItem
          Caption = 'NORM.S.INV'
          Description = 
            'Iteratively calculates the inverse of the standard normal cumula' +
            'tive distribution. The standard distribution'#8217's arithmetic mean a' +
            'nd standard deviation are 0 and 1, respectively.'
          ActionIndex = 'NORM.S.INV'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item46: TdxRibbonGalleryGroupItem
          Caption = 'PEARSON'
          Description = 
            'Returns the Pearson product moment correlation coefficient (R), ' +
            'a dimensionless index that ranges within the range between -1.0 ' +
            'and 1.0, inclusive, and reflects the extent of a linear relation' +
            'ship between two data sets.'
          ActionIndex = 'PEARSON'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item47: TdxRibbonGalleryGroupItem
          Caption = 'PERCENTILE.EXC'
          Description = 
            'Returns the K-th percentile of values in an array of numbers, wh' +
            'ere K is the range between 0 and 1, exclusive.'
          ActionIndex = 'PERCENTILE.EXC'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item48: TdxRibbonGalleryGroupItem
          Caption = 'PERCENTILE.INC'
          Description = 'Returns the K-th percentile of values in an array of numbers.'
          ActionIndex = 'PERCENTILE.INC'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item49: TdxRibbonGalleryGroupItem
          Caption = 'PERMUT'
          Description = 
            'Returns the number of permutations for the specified number of o' +
            'bjects.'
          ActionIndex = 'PERMUT'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item50: TdxRibbonGalleryGroupItem
          Caption = 'POISSON.DIST'
          Description = 
            'Returns the Poisson distribution that is often used to predict t' +
            'he number of events occurring over  a specific time.'
          ActionIndex = 'POISSON.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item51: TdxRibbonGalleryGroupItem
          Caption = 'QUARTILE.EXC'
          Description = 
            'Returns the quartile of a series of numeric values, based on per' +
            'centile values from the range between 0 and 1, exclusive.'
          ActionIndex = 'QUARTILE.EXC'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item52: TdxRibbonGalleryGroupItem
          Caption = 'QUARTILE.INC'
          Description = 'Returns the quartile of a series of numeric values.'
          ActionIndex = 'QUARTILE.INC'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item53: TdxRibbonGalleryGroupItem
          Caption = 'RANK.AVG'
          Description = 
            'Returns the rank of a specified number in a series of values. Th' +
            'e number'#8217's rank (magnitude) is relative to other values in the l' +
            'ist. The function returns the average rank if more than one valu' +
            'e has the same rank.'
          ActionIndex = 'RANK.AVG'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item54: TdxRibbonGalleryGroupItem
          Caption = 'RANK.EQ'
          Description = 
            'Returns the rank of a specified number in a series of values. Th' +
            'e rank is a magnitude of a numeric value in relation to all othe' +
            'r values in the source array. The rank matches the value'#8217's numbe' +
            'r in the sorted array.'
          ActionIndex = 'RANK.EQ'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item55: TdxRibbonGalleryGroupItem
          Caption = 'RSQ'
          Description = 
            'Returns the square of the Pearson product moment correlation coe' +
            'fficient through data points.'
          ActionIndex = 'RSQ'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item56: TdxRibbonGalleryGroupItem
          Caption = 'SKEW'
          Description = 
            'Returns the skewness of a distribution. Skewness characterizes t' +
            'he degree of asymmetry of a distribution around its mean.'
          ActionIndex = 'SKEW'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item57: TdxRibbonGalleryGroupItem
          Caption = 'SKEW.P'
          Description = 
            'Returns the skewness of a distribution based on a population: a ' +
            'characterization of the degree of asymmetry of a distribution ar' +
            'ound its mean.'
          ActionIndex = 'SKEW.P'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item58: TdxRibbonGalleryGroupItem
          Caption = 'SLOPE'
          Description = 'Returns the slope of the linear regression line.'
          ActionIndex = 'SLOPE'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item59: TdxRibbonGalleryGroupItem
          Caption = 'SMALL'
          Description = 'Returns the K-th smallest value in a series of numeric values.'
          ActionIndex = 'SMALL'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item60: TdxRibbonGalleryGroupItem
          Caption = 'STANDARDIZE'
          Description = 
            'Returns a normalized value from a distribution characterized by ' +
            'the mean and standard deviation values.'
          ActionIndex = 'STANDARDIZE'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item61: TdxRibbonGalleryGroupItem
          Caption = 'STDEV.P'
          Description = 
            'Calculates the standard deviation based on the entire population' +
            ' passed as an array of numeric values. The standard deviation in' +
            'dicates how widely values within a series of numbers disperse fr' +
            'om the average value (that is, the mean).'
          ActionIndex = 'STDEV.P'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item62: TdxRibbonGalleryGroupItem
          Caption = 'STDEV.S'
          Description = 
            'Estimates the standard deviation based on the specified array of' +
            ' numeric values (a sample of the population). The standard devia' +
            'tion indicates how widely values within a series of numbers disp' +
            'erse from the average value (that is, the mean).'
          ActionIndex = 'STDEV.S'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item63: TdxRibbonGalleryGroupItem
          Caption = 'STDEVA'
          Description = 
            'Estimates the standard deviation based on the specified array (a' +
            ' sample of the population), including numeric values, text, and ' +
            'logical values.'
          ActionIndex = 'STDEVA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item64: TdxRibbonGalleryGroupItem
          Caption = 'STDEVPA'
          Description = 
            'Calculates the standard deviation based on the entire population' +
            ' passed as an array, including numeric values, text, and logical' +
            ' values.'
          ActionIndex = 'STDEVPA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item65: TdxRibbonGalleryGroupItem
          Caption = 'STEYX'
          Description = 
            'Returns the standard error of the predicted Y-value for each X i' +
            'n the regression. The standard error is a measure of the amount ' +
            'of error in the prediction of Y for an individual X.'
          ActionIndex = 'STEYX'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item66: TdxRibbonGalleryGroupItem
          Caption = 'T.DIST'
          Description = 
            'Returns the Percentage Points (that is, the probability) for the' +
            ' Student'#8217's T-distribution. The T-distribution is used in the hyp' +
            'othesis testing of small sample data sets.'
          ActionIndex = 'T.DIST'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item67: TdxRibbonGalleryGroupItem
          Caption = 'T.DIST.2T'
          Description = 
            'Returns the two-tailed Student'#8217's T-distribution. You can use thi' +
            's function instead of a table of critical values for the T-distr' +
            'ibution.'
          ActionIndex = 'T.DIST.2T'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item68: TdxRibbonGalleryGroupItem
          Caption = 'T.DIST.RT'
          Description = 'Returns the right-tailed T-distribution.'
          ActionIndex = 'T.DIST.RT'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item69: TdxRibbonGalleryGroupItem
          Caption = 'T.INV'
          Description = 
            'Returns the T-value of the Student'#8217's T-distribution as a functio' +
            'n of the probability and the degrees of freedom.'
          ActionIndex = 'T.INV'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item70: TdxRibbonGalleryGroupItem
          Caption = 'T.INV.2T'
          Description = 
            'Iteratively calculates the two-tailed inverse of the Student'#8217's T' +
            '-distribution.'
          ActionIndex = 'T.INV.2T'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item71: TdxRibbonGalleryGroupItem
          Caption = 'VAR.P'
          Description = 
            'Calculates the variance based on the entire population specified' +
            ' as an array of numeric values.'
          ActionIndex = 'VAR.P'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item72: TdxRibbonGalleryGroupItem
          Caption = 'VAR.S'
          Description = 
            'Estimates variance based on the specified array of numeric value' +
            's (a sample of the population).'
          ActionIndex = 'VAR.S'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item73: TdxRibbonGalleryGroupItem
          Caption = 'VARA'
          Description = 
            'Estimates variance based on the specified array (a sample of the' +
            ' population), including numeric values, text, and logical values' +
            '.'
          ActionIndex = 'VARA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item74: TdxRibbonGalleryGroupItem
          Caption = 'VARPA'
          Description = 
            'Calculates the variance based on the entire population specified' +
            ' as an array, including numeric values, text, and logical values' +
            '.'
          ActionIndex = 'VARPA'
        end
        object dxRibbonGalleryItemStatisticalGroup1Item75: TdxRibbonGalleryGroupItem
          Caption = 'WEIBULL.DIST'
          Description = 
            'Returns the Weibull distribution used in reliability analysis. Y' +
            'ou can use this function to calculate a device'#8217's MBTF (mean time' +
            ' between failures).'
          ActionIndex = 'WEIBULL.DIST'
        end
      end
    end
    object dxRibbonGalleryItemInformation: TdxRibbonGalleryItem
      Action = dxSpreadSheetInformationFormulasGallery
      Category = 11
      ImageIndex = 404
      LargeImageIndex = 404
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemInformationGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemInformationGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'ISBLANK'
          Description = 'Returns TRUE if cell is empty.'
          ActionIndex = 'ISBLANK'
        end
        object dxRibbonGalleryItemInformationGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'ISERR'
          Description = 'Returns TRUE if the cell contains any error code except #N/A.'
          ActionIndex = 'ISERR'
        end
        object dxRibbonGalleryItemInformationGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'ISERROR'
          Description = 
            'Returns TRUE if the cell contains any error code (#N/A, #VALUE!,' +
            ' #REF!, #DIV/0!, #NUM!, #NAME?, or #NULL!).'
          ActionIndex = 'ISERROR'
        end
        object dxRibbonGalleryItemInformationGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'ISEVEN'
          Description = 'Returns TRUE if the number is even.'
          ActionIndex = 'ISEVEN'
        end
        object dxRibbonGalleryItemInformationGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'ISLOGICAL'
          Description = 'Returns TRUE if the specified value refers to a logical value.'
          ActionIndex = 'ISLOGICAL'
        end
        object dxRibbonGalleryItemInformationGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'ISNA'
          Description = 
            'Returns TRUE if the cell contains the #N/A (a value is not avail' +
            'able) error code.'
          ActionIndex = 'ISNA'
        end
        object dxRibbonGalleryItemInformationGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'ISNONTEXT'
          Description = 
            'Returns TRUE if the cell does not contain text. Returns TRUE for' +
            ' blank cells.'
          ActionIndex = 'ISNONTEXT'
        end
        object dxRibbonGalleryItemInformationGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'ISNUMBER'
          Description = 'Returns TRUE if the cell contains a number.'
          ActionIndex = 'ISNUMBER'
        end
        object dxRibbonGalleryItemInformationGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'ISODD'
          Description = 'Returns TRUE if the number is odd.'
          ActionIndex = 'ISODD'
        end
        object dxRibbonGalleryItemInformationGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'ISREF'
          Description = 'Returns TRUE if the cell contains a reference.'
          ActionIndex = 'ISREF'
        end
        object dxRibbonGalleryItemInformationGroup1Item11: TdxRibbonGalleryGroupItem
          Caption = 'ISTEXT'
          Description = 'Returns TRUE if the specified cell contains text.'
          ActionIndex = 'ISTEXT'
        end
        object dxRibbonGalleryItemInformationGroup1Item12: TdxRibbonGalleryGroupItem
          Caption = 'N'
          Description = 'Returns a value converted to a number.'
          ActionIndex = 'N'
        end
        object dxRibbonGalleryItemInformationGroup1Item13: TdxRibbonGalleryGroupItem
          Caption = 'NA'
          Description = 'Returns the error code #N/A.'
          ActionIndex = 'NA'
        end
      end
    end
    object dxRibbonGalleryItemCompatibility: TdxRibbonGalleryItem
      Action = dxSpreadSheetCompatibilityFormulasGallery
      Category = 11
      ImageIndex = 399
      LargeImageIndex = 399
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemCompatibilityGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemCompatibilityGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'BETADIST'
          Description = 
            'Returns the cumulative beta probability density function. The be' +
            'ta distribution is useful to study variation of a specific indic' +
            'ator (as a percentage) across samples.'
          ActionIndex = 'BETADIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'BETAINV'
          Description = 
            'Returns the inverse of the cumulative beta probability density f' +
            'unction for the specified beta distribution probability.'
          ActionIndex = 'BETAINV'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'BINOMDIST'
          Description = 
            'Returns the individual term binominal distribution probability. ' +
            'You can use this function to evaluate a mixed number of independ' +
            'ent trials that can result only in success or failure, provided ' +
            'that the probability of success does not change throughout the e' +
            'xperiment.'
          ActionIndex = 'BINOMDIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'CHIDIST'
          Description = 
            'Returns the two-tailed probability of the chi-squared distributi' +
            'on. You can use this function to calculate the variation of a ce' +
            'rtain indicator across the experimental data.'
          ActionIndex = 'CHIDIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'CHIINV'
          Description = 
            'Iteratively calculates the inverse of the right-tailed probabili' +
            'ty of the chi-squared distribution.'
          ActionIndex = 'CHIINV'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'COVAR'
          Description = 
            'Calculates the average of the products of deviations (that is, c' +
            'ovariance) for each pair of values in the specified arrays of in' +
            'tegers. You can use this function to identify the relationship b' +
            'etween two sets of values.'
          ActionIndex = 'COVAR'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'EXPONDIST'
          Description = 
            'Returns the exponential distribution. This function is useful if' +
            ' you need to evaluate the process duration probabilities.'
          ActionIndex = 'EXPONDIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'GAMMADIST'
          Description = 
            'Returns the gamma distribution. You can use this function to stu' +
            'dy a series of numbers that may have a skewed distribution. The ' +
            'gamma distribution is commonly used in queuing analysis.'
          ActionIndex = 'GAMMADIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'GAMMAINV'
          Description = 
            'Iteratively calculates the inverse of the gamma cumulative distr' +
            'ibution. The gamma distribution is useful to study values that h' +
            'ave a skewed distribution.'
          ActionIndex = 'GAMMAINV'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'HYPGEOMDIST'
          Description = 
            'Returns the hypergeometric distribution, that is, the probabilit' +
            'y of a specified number of sample successes at a specific sample' +
            ' size, number of population successes, and population size.'
          ActionIndex = 'HYPGEOMDIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item11: TdxRibbonGalleryGroupItem
          Caption = 'NORMDIST'
          Description = 
            'Returns the normal distribution for the specified mean and stand' +
            'ard distribution. This function is widely used in statistics, in' +
            'cluding hypothesis testing.'
          ActionIndex = 'NORMDIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item12: TdxRibbonGalleryGroupItem
          Caption = 'NORMINV'
          Description = 
            'Iteratively calculates the inverse of the normal distribution of' +
            ' the specified mean and standard deviation.'
          ActionIndex = 'NORMINV'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item13: TdxRibbonGalleryGroupItem
          Caption = 'NORMSDIST'
          Description = 
            'Returns the standard normal cumulative distribution function. Th' +
            'e standard distribution'#8217's arithmetic mean and standard deviation' +
            ' are 0 and 1, respectively.'
          ActionIndex = 'NORMSDIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item14: TdxRibbonGalleryGroupItem
          Caption = 'NORMSINV'
          Description = 
            'Iteratively calculates the inverse of the standard normal cumula' +
            'tive distribution. The standard distribution'#8217's arithmetic mean a' +
            'nd standard deviation are 0 and 1, respectively.'
          ActionIndex = 'NORMSINV'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item15: TdxRibbonGalleryGroupItem
          Caption = 'PERCENTILE'
          Description = 'Returns the K-th percentile of values in an array of numbers.'
          ActionIndex = 'PERCENTILE'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item16: TdxRibbonGalleryGroupItem
          Caption = 'POISSON'
          Description = 
            'Returns the Poisson distribution that is often used to predict t' +
            'he number of events occurring over a specific time.'
          ActionIndex = 'POISSON'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item17: TdxRibbonGalleryGroupItem
          Caption = 'QUARTILE'
          Description = 'Returns the quartile of a series of numeric values.'
          ActionIndex = 'QUARTILE'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item18: TdxRibbonGalleryGroupItem
          Caption = 'RANK'
          Description = 
            'Returns the rank of a specific number in a series of values. The' +
            ' rank is a magnitude of a numeric value in relation to all other' +
            ' values in the source array. This rank matches the value'#8217's numbe' +
            'r in a sorted array.'
          ActionIndex = 'RANK'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item19: TdxRibbonGalleryGroupItem
          Caption = 'STDEV'
          Description = 
            'Estimates the standard deviation based on the specified array of' +
            ' numeric values (a sample of the population). The standard devia' +
            'tion indicates how widely values within a series of numbers disp' +
            'erse from the average value (that is, the mean).'
          ActionIndex = 'STDEV'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item20: TdxRibbonGalleryGroupItem
          Caption = 'STDEVP'
          Description = 
            'Calculates the standard deviation based on the entire population' +
            ' specified as an array of numeric values. The standard deviation' +
            ' indicates how widely values within a series of numbers disperse' +
            ' from the average value (that is, the mean).'
          ActionIndex = 'STDEVP'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item21: TdxRibbonGalleryGroupItem
          Caption = 'TDIST'
          Description = 
            'Returns the Percentage Points (that is, the probability) for the' +
            ' Student T-distribution. The T-distribution is used in the hypot' +
            'hesis testing of small sample data sets.'
          ActionIndex = 'TDIST'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item22: TdxRibbonGalleryGroupItem
          Caption = 'TINV'
          Description = 
            'Iteratively calculates the two-tailed inverse of the Student'#8217's T' +
            '-distribution.'
          ActionIndex = 'TINV'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item23: TdxRibbonGalleryGroupItem
          Caption = 'VAR'
          Description = 
            'Estimates variance based on the specified array of numeric value' +
            's (a sample of the population).'
          ActionIndex = 'VAR'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item24: TdxRibbonGalleryGroupItem
          Caption = 'VARP'
          Description = 
            'Calculates variance based on the entire population specified as ' +
            'an array of numeric values.'
          ActionIndex = 'VARP'
        end
        object dxRibbonGalleryItemCompatibilityGroup1Item25: TdxRibbonGalleryGroupItem
          Caption = 'WEIBULL'
          Description = 
            'Returns the Weibull distribution used in reliability analysis. Y' +
            'ou can use this function to calculate a device'#8217's MBTF (mean time' +
            ' between failures).'
          ActionIndex = 'WEIBULL'
        end
      end
    end
    object dxBarLargeButtonNameManager: TdxBarLargeButton
      Action = dxSpreadSheetShowDefinedNameManager
      Caption = 'Gestione nomi'
      Category = 12
      LargeImageIndex = 409
      SyncImageIndex = False
      ImageIndex = 409
    end
    object dxBarButtonDefineName: TdxBarButton
      Action = dxSpreadSheetCreateDefinedName
      Category = 12
      ImageIndex = 402
      LargeImageIndex = 402
    end
    object dxRibbonGalleryItemUseinFormula: TdxRibbonGalleryItem
      Action = dxSpreadSheetUseDefinedNameInFormula
      Caption = 'Usa nella formula'
      Category = 12
      ImageIndex = 401
      LargeImageIndex = 401
      GalleryOptions.ColumnCount = 1
      GalleryOptions.LongDescriptionDefaultRowCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <>
      object dxRibbonGalleryItemUseinFormulaGroup1: TdxRibbonGalleryGroup
      end
    end
    object dxBarButtonCreatefromSelection: TdxBarButton
      Action = dxSpreadSheetCreateDefinedNamesFromSelection
      Caption = 'Crea da selezione'
      Category = 12
      ImageIndex = 400
      LargeImageIndex = 400
    end
    object dxBarLargeButtonSortAtoZ: TdxBarLargeButton
      Action = dxSpreadSheetSortAscending
      Category = 13
      LargeImageIndex = 200
      SyncImageIndex = False
      ImageIndex = 200
    end
    object dxBarLargeButtonSortZtoA: TdxBarLargeButton
      Action = dxSpreadSheetSortDescending
      Category = 13
      LargeImageIndex = 201
      SyncImageIndex = False
      ImageIndex = 201
    end
    object dxBarSubItem11: TdxBarSubItem
      Caption = 'Raggruppa'
      Category = 14
      Visible = ivAlways
      ImageIndex = 155
      LargeImageIndex = 155
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonGroupColumns'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonGroupRows'
        end>
    end
    object dxBarLargeButtonGroupColumns: TdxBarLargeButton
      Action = dxSpreadSheetGroupColumns
      Category = 14
      LargeImageIndex = 155
      SyncImageIndex = False
      ImageIndex = 155
    end
    object dxBarLargeButtonGroupRows: TdxBarLargeButton
      Action = dxSpreadSheetGroupRows
      Category = 14
      LargeImageIndex = 155
      SyncImageIndex = False
      ImageIndex = 155
    end
    object dxBarSubItem12: TdxBarSubItem
      Caption = 'Separa'
      Category = 14
      Visible = ivAlways
      ImageIndex = 176
      LargeImageIndex = 176
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUngroupColumns'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUngroupRows'
        end>
    end
    object dxBarLargeButtonUngroupColumns: TdxBarLargeButton
      Action = dxSpreadSheetUngroupColumns
      Category = 14
      LargeImageIndex = 176
      SyncImageIndex = False
      ImageIndex = 176
    end
    object dxBarLargeButtonUngroupRows: TdxBarLargeButton
      Action = dxSpreadSheetUngroupRows
      Category = 14
      LargeImageIndex = 176
      SyncImageIndex = False
      ImageIndex = 176
    end
    object dxBarLargeButtonNewComment: TdxBarLargeButton
      Action = dxSpreadSheetNewComment
      Category = 15
      LargeImageIndex = 101
      SyncImageIndex = False
      ImageIndex = 101
    end
    object dxBarLargeButtonEditComment: TdxBarLargeButton
      Action = dxSpreadSheetEditComment
      Category = 15
      LargeImageIndex = 78
      SyncImageIndex = False
      ImageIndex = 78
    end
    object dxBarLargeButtonDeleteComments: TdxBarLargeButton
      Action = dxSpreadSheetDeleteComments
      Caption = 'Elimina commento'
      Category = 15
      LargeImageIndex = 68
      SyncImageIndex = False
      ImageIndex = 68
    end
    object dxBarLargeButtonPreviousComment: TdxBarLargeButton
      Action = dxSpreadSheetPreviousComment
      Category = 15
      LargeImageIndex = 170
      SyncImageIndex = False
      ImageIndex = 170
    end
    object dxBarLargeButtonNextComment: TdxBarLargeButton
      Action = dxSpreadSheetNextComment
      Caption = 'Commento successivo'
      Category = 15
      LargeImageIndex = 162
      SyncImageIndex = False
      ImageIndex = 162
    end
    object dxBarLargeButtonShowHideComments: TdxBarLargeButton
      Action = dxSpreadSheetShowHideComments
      Caption = 'Mostra/nascondi commenti'
      Category = 15
      ButtonStyle = bsChecked
      LargeImageIndex = 451
      SyncImageIndex = False
      ImageIndex = 451
    end
    object dxBarLargeButtonProtectSheet: TdxBarLargeButton
      Action = dxSpreadSheetProtectSheet
      Caption = 'Proteggi foglio'
      Category = 16
      ButtonStyle = bsChecked
      LargeImageIndex = 494
      SyncImageIndex = False
      ImageIndex = 494
    end
    object dxBarLargeButtonProtectWorkbook: TdxBarLargeButton
      Action = dxSpreadSheetProtectWorkbook
      Caption = 'Proteggi cartella di lavoro'
      Category = 16
      ButtonStyle = bsChecked
      LargeImageIndex = 495
      SyncImageIndex = False
      ImageIndex = 495
    end
    object dxBarLargeButtonZoomOut: TdxBarLargeButton
      Action = dxSpreadSheetZoomOut
      Caption = 'Riduci'
      Category = 17
      LargeImageIndex = 460
      SyncImageIndex = False
      ImageIndex = 460
    end
    object dxBarLargeButtonZoomIn: TdxBarLargeButton
      Action = dxSpreadSheetZoomIn
      Caption = 'Ingrandisci'
      Category = 17
      LargeImageIndex = 459
      SyncImageIndex = False
      ImageIndex = 459
    end
    object dxBarLargeButton100: TdxBarLargeButton
      Action = dxSpreadSheetZoomDefault
      Category = 17
      LargeImageIndex = 458
      SyncImageIndex = False
      ImageIndex = 458
    end
    object dxBarSubItem13: TdxBarSubItem
      Caption = 'Blocca riquadri'
      Category = 18
      Visible = ivAlways
      ImageIndex = 272
      LargeImageIndex = 272
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonFreezePanes'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUnfreezePanes'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonFreezeTopRow'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonFreezeFirstColumn'
        end>
    end
    object dxBarLargeButtonFreezePanes: TdxBarLargeButton
      Action = dxSpreadSheetFreezePanes
      Category = 18
      LargeImageIndex = 272
      SyncImageIndex = False
      ImageIndex = 272
    end
    object dxBarLargeButtonUnfreezePanes: TdxBarLargeButton
      Action = dxSpreadSheetUnfreezePanes
      Category = 18
      LargeImageIndex = 174
      SyncImageIndex = False
      ImageIndex = 174
    end
    object dxBarLargeButtonFreezeTopRow: TdxBarLargeButton
      Action = dxSpreadSheetFreezeTopRow
      Category = 18
      LargeImageIndex = 273
      SyncImageIndex = False
      ImageIndex = 273
    end
    object dxBarLargeButtonFreezeFirstColumn: TdxBarLargeButton
      Action = dxSpreadSheetFreezeFirstColumn
      Category = 18
      LargeImageIndex = 271
      SyncImageIndex = False
      ImageIndex = 271
    end
    object dxBarSubItem14: TdxBarSubItem
      Caption = 'Formattazione condizionale'
      Category = 19
      Visible = ivAlways
      ImageIndex = 378
      LargeImageIndex = 378
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemTopBottomRules'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemDataBars'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemColorScales'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemIconSets'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonNewRule'
        end
        item
          Visible = True
          ItemName = 'dxBarSubItem15'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonManageRules'
        end>
    end
    object dxRibbonGalleryItemTopBottomRules: TdxRibbonGalleryItem
      Action = dxSpreadSheetConditionalFormattingTopBottomRulesGallery
      Category = 19
      ImageIndex = 394
      LargeImageIndex = 394
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMoreRules'
        end>
      object dxRibbonGalleryItemTopBottomRulesGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        object dxRibbonGalleryItemTopBottomRulesGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Top 10 Items'
          ImageIndex = 392
          ActionIndex = 0
        end
        object dxRibbonGalleryItemTopBottomRulesGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Top 10%'
          ImageIndex = 391
          ActionIndex = 1
        end
        object dxRibbonGalleryItemTopBottomRulesGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Bottom 10 Items'
          ImageIndex = 368
          ActionIndex = 2
        end
        object dxRibbonGalleryItemTopBottomRulesGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'Bottom 10%'
          ImageIndex = 136
          ActionIndex = 3
        end
        object dxRibbonGalleryItemTopBottomRulesGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'Above Average'
          ImageIndex = 362
          ActionIndex = 4
        end
        object dxRibbonGalleryItemTopBottomRulesGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'Below Average'
          ImageIndex = 366
          ActionIndex = 5
        end
      end
    end
    object dxBarLargeButtonMoreRules: TdxBarLargeButton
      Action = dxSpreadSheetConditionalFormattingMoreRules
      Category = 19
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxRibbonGalleryItemDataBars: TdxRibbonGalleryItem
      Action = dxSpreadSheetConditionalFormattingDataBarsGallery
      Category = 19
      ImageIndex = 215
      LargeImageIndex = 215
      GalleryOptions.ColumnCount = 3
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkNone
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMoreRules'
        end>
      object dxRibbonGalleryItemDataBarsGroup1: TdxRibbonGalleryGroup
        Header.Caption = 'Gradient Fill'
        Header.Visible = True
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemDataBarsGroup1Item1: TdxRibbonGalleryGroupItem
          ImageIndex = 214
          ActionIndex = 0
        end
        object dxRibbonGalleryItemDataBarsGroup1Item2: TdxRibbonGalleryGroupItem
          ImageIndex = 227
          ActionIndex = 1
        end
        object dxRibbonGalleryItemDataBarsGroup1Item3: TdxRibbonGalleryGroupItem
          ImageIndex = 231
          ActionIndex = 2
        end
        object dxRibbonGalleryItemDataBarsGroup1Item4: TdxRibbonGalleryGroupItem
          ImageIndex = 229
          ActionIndex = 3
        end
        object dxRibbonGalleryItemDataBarsGroup1Item5: TdxRibbonGalleryGroupItem
          ImageIndex = 228
          ActionIndex = 4
        end
        object dxRibbonGalleryItemDataBarsGroup1Item6: TdxRibbonGalleryGroupItem
          ImageIndex = 230
          ActionIndex = 5
        end
      end
      object dxRibbonGalleryItemDataBarsGroup2: TdxRibbonGalleryGroup
        Header.Caption = 'Solid Fill'
        Header.Visible = True
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemDataBarsGroup2Item1: TdxRibbonGalleryGroupItem
          ImageIndex = 215
          ActionIndex = 6
        end
        object dxRibbonGalleryItemDataBarsGroup2Item2: TdxRibbonGalleryGroupItem
          ImageIndex = 233
          ActionIndex = 7
        end
        object dxRibbonGalleryItemDataBarsGroup2Item3: TdxRibbonGalleryGroupItem
          ImageIndex = 245
          ActionIndex = 8
        end
        object dxRibbonGalleryItemDataBarsGroup2Item4: TdxRibbonGalleryGroupItem
          ImageIndex = 246
          ActionIndex = 9
        end
        object dxRibbonGalleryItemDataBarsGroup2Item5: TdxRibbonGalleryGroupItem
          ImageIndex = 239
          ActionIndex = 10
        end
        object dxRibbonGalleryItemDataBarsGroup2Item6: TdxRibbonGalleryGroupItem
          ImageIndex = 242
          ActionIndex = 11
        end
      end
    end
    object dxRibbonGalleryItemColorScales: TdxRibbonGalleryItem
      Action = dxSpreadSheetConditionalFormattingColorScalesGallery
      Category = 19
      ImageIndex = 383
      LargeImageIndex = 383
      GalleryOptions.ColumnCount = 4
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkNone
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMoreRules'
        end>
      object dxRibbonGalleryItemColorScalesGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemColorScalesGroup1Item1: TdxRibbonGalleryGroupItem
          ImageIndex = 383
          ActionIndex = 0
        end
        object dxRibbonGalleryItemColorScalesGroup1Item2: TdxRibbonGalleryGroupItem
          ImageIndex = 383
          ActionIndex = 1
        end
        object dxRibbonGalleryItemColorScalesGroup1Item3: TdxRibbonGalleryGroupItem
          ImageIndex = 381
          ActionIndex = 2
        end
        object dxRibbonGalleryItemColorScalesGroup1Item4: TdxRibbonGalleryGroupItem
          ImageIndex = 381
          ActionIndex = 3
        end
        object dxRibbonGalleryItemColorScalesGroup1Item5: TdxRibbonGalleryGroupItem
          ImageIndex = 367
          ActionIndex = 4
        end
        object dxRibbonGalleryItemColorScalesGroup1Item6: TdxRibbonGalleryGroupItem
          ImageIndex = 367
          ActionIndex = 5
        end
        object dxRibbonGalleryItemColorScalesGroup1Item7: TdxRibbonGalleryGroupItem
          ImageIndex = 390
          ActionIndex = 6
        end
        object dxRibbonGalleryItemColorScalesGroup1Item8: TdxRibbonGalleryGroupItem
          ImageIndex = 390
          ActionIndex = 7
        end
        object dxRibbonGalleryItemColorScalesGroup1Item9: TdxRibbonGalleryGroupItem
          ImageIndex = 380
          ActionIndex = 8
        end
        object dxRibbonGalleryItemColorScalesGroup1Item10: TdxRibbonGalleryGroupItem
          ImageIndex = 380
          ActionIndex = 9
        end
        object dxRibbonGalleryItemColorScalesGroup1Item11: TdxRibbonGalleryGroupItem
          ImageIndex = 382
          ActionIndex = 10
        end
        object dxRibbonGalleryItemColorScalesGroup1Item12: TdxRibbonGalleryGroupItem
          ImageIndex = 382
          ActionIndex = 11
        end
      end
    end
    object dxRibbonGalleryItemIconSets: TdxRibbonGalleryItem
      Action = dxSpreadSheetConditionalFormattingIconSetsGallery
      Category = 19
      ImageIndex = 384
      LargeImageIndex = 384
      GalleryOptions.ColumnCount = 2
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkNone
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMoreRules'
        end>
      object dxRibbonGalleryItemIconSetsGroup1: TdxRibbonGalleryGroup
        Header.Caption = 'Directional'
        Header.Visible = True
        object dxRibbonGalleryItemIconSetsGroup1Item1: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000900000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000020000000500000003000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000030000000B0000001100000013000000130000
            0013000000120000000C00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000060403
            1034181366C803020D3400000006000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000071B4796E30206112D0000
            0003000000010000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000000000000A1543
            2FC31F5E43FF1F5D42FF1F5D41FF1E5C42FF1F5C41FF15422FC30000000B0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000010000000504031134252388E84450CAFF1A1872E803020E350000
            0006000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000091F53AAFF193F86E80207112D0000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000F2B7457FF72D7BAFF54CAA6FF52CAA5FF52C9
            A4FF52C9A4FF2A7154FF00000010000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000505041132282389E74D5C
            D6FF4658DDFF4858D2FF1C1B75EA03020E340000000600000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000082056ABFF64AFE2FF183E
            85E70207122C0000000300000001000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000000000000E2C77
            59FF76D8BCFF46C59DFF46C59DFF45C49CFF54CBA7FF2A7456FF000000100000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            0005050411312B288BE75261D8FF495CDFFF4659DEFF475BDFFF4C5DD5FF1C1B
            75EA03020E330000000500000001000000000000000000000000000000000000
            0000000000000000000000000005000000070000000800000008000000080000
            00080000000F2157ADFF73C3EFFF54A7DFFF183F85E70207122C000000030000
            0001000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000D2C795BFF79DABEFF48C59FFF47C69EFF47C6
            9EFF58CCA9FF2B7659FF0000000F000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000040504122F2D298EE65868DAFF4E61E1FF4B5E
            DFFF4A5DDFFF4A5DDFFF4B5EDFFF5160D6FF1E1C77EA03020E31000000050000
            000100000000000000000000000000000000000000000000000012346CBC1A4B
            A0FF194A9EFF19499DFF19499EFF19489DFF19479CFF2159AEFF67BDEEFF57B3
            EBFF58AAE1FF184088E70207122B000000030000000100000000000000000000
            00000000000000000000000000000000000000000000000000000000000C2D7C
            5EFF7CDBC1FF4AC7A1FF4AC7A0FF49C7A0FF5BCEACFF2C795BFF0000000E0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000040505122D312D
            8FE65E6EDCFF5467E3FF5064E1FF4F63E1FF4E63E1FF4E62E1FF4D61E0FF4F63
            E1FF5464D8FF1E1D79E903020E31000000050000000100000000000000000000
            000000000000000000002562AEFF89D1F4FF76C7F2FF74C7F0FF72C4F1FF72C4
            F0FF70C3F0FF6FC2F0FF6DC1F0FF5BB7ECFF5CB7EDFF5DADE2FF194089E70207
            122B000000030000000100000000000000000000000000000000000000000000
            000000000000000000000000000B2E7F60FF7FDBC1FF4CC8A2FF4CC8A1FF4BC8
            A1FF5ECFAEFF2C7C5EFF0000000D000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000605132B353192E57B8BE3FF8697EDFF8596EDFF7789EBFF5468
            E2FF5467E2FF5367E3FF6679E6FF7484E9FF7F8FECFF7381DFFF25237AE90303
            0E2F0000000300000000000000000000000000000000000000002867B2FF8FD5
            F5FF69C3F1FF68C2F0FF67C1F0FF65C0EFFF64C0EFFF63BFEFFF62BEEEFF60BC
            EFFF5FBBEEFF61BCEEFF61B1E3FF1B448AE70207122A00000002000000000000
            000000000000000000000000000000000007000000090000000A000000112F83
            63FF82DDC4FF4EC9A4FF4DC9A3FF4DC9A3FF62D0B0FF2E7F60FF000000150000
            000C0000000C0000000900000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000005354AEE06162C7FF6161
            C7FF6061C7FF453EB1FF7C8EEBFF586DE4FF576CE4FF576BE4FF6B7EE8FF3C34
            AAFF5D5DC3FF5D5CC3FF5C5CC3FF5050ADE40000000700000000000000000000
            00000000000000000000296BB4FF95DAF7FF6FC9F3FF6EC8F1FF6EC7F3FF6CC5
            F1FF6AC4F0FF6AC4F0FF68C3F0FF67C1F0FF66C0EFFF64BFF0FF69C2F0FF6FB4
            E3FF1B4586C70000000400000000000000000000000000000000000000002064
            49E0247453FF247253FF237152FF308566FF67D4B5FF4FCBA6FF4FCBA5FF4FCA
            A5FF65D3B2FF2F8263FF236C4EFF226B4EFF226A4EFF1E5E44E4000000060000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000060000000800000009000000104843B4FF8193ECFF5D72
            E5FF5C72E5FF5C71E5FF7084E8FF3F38ADFF000000130000000B0000000B0000
            00080000000200000000000000000000000000000000000000002D71B8FF9CDE
            F8FF76CEF4FF75CDF4FF74CDF4FF73CBF4FF71CBF3FF70C9F3FF6FC8F1FF6EC8
            F3FF6CC7F1FF6FC6F1FF7FC6ECFF2B5EA2E6040B142600000001000000000000
            000000000000000000000000000006100D2739866BE592DBC6FF8AE0C9FF70D8
            B9FF6BD5B7FF52CCA7FF51CCA7FF51CBA7FF68D4B6FF67D4B4FF6AD4B6FF78D1
            B6FF2E6F56E8040D092A00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000084B46B8FF8899EEFF6378E7FF6177E6FF6176E6FF7689EAFF413B
            AFFF0000000A0000000000000000000000000000000000000000000000000000
            000000000000000000002F76BBFFAFE7FBFFAEE6FAFFADE5FAFFACE5F9FFABE4
            F9FFAAE2F9FFA8E2F9FF99DBF8FF75CDF4FF77CEF4FF87CAEFFF2C61A6E6040B
            1426000000020000000000000000000000000000000000000000000000000000
            000206110D2639886DE591DCC6FF77D9BEFF59CFACFF54CEA9FF53CDA9FF54CD
            A8FF52CDA8FF5ACFACFF79D1B9FF32715AE7050D0A2900000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000074F4ABAFF8C9DEEFF677D
            E8FF677CE8FF667BE8FF7C8FECFF443EB2FF0000000800000000000000000000
            0000000000000000000000000000000000000000000000000000235A8DC03784
            C6FF3783C5FF3682C5FF3682C4FF3581C4FF3581C4FF3580C3FF9FE0F8FF7ED5
            F5FF8DCFF0FF3064A7E6040B1525000000020000000000000000000000000000
            0000000000000000000000000000000000000000000206110D253C8B6FE493DD
            C8FF79DABFFF5AD1AEFF55CFAAFF55CEAAFF5CD0AEFF7CD3BBFF34775BE7050E
            0A28000000030000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000006514EBCFF8FA2F0FF6C81EAFF6C80EAFF6B80EAFF8194EEFF4742
            B5FF000000070000000000000000000000000000000000000000000000000000
            0000000000000000000000000003000000040000000400000004000000040000
            0004000000083783C6FFA8E5FAFF94D4F1FF3268A9E6050C1524000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000106110D243D8B71E495DDCAFF7BDCC0FF5CD1AEFF5FD1
            B0FF80D4BCFF337A5DE6050E0A26000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000055451BFFF94A6F1FF6F85
            EBFF6F85EBFF6E84EBFF8499EFFF4A45B7FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000043987C8FFA3DAF3FF336A
            AAE6050C15230000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010612
            0E233E8E72E495DDCBFF83DFC5FF84D7BFFF347D61E6050F0B24000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000045855C2FFA2B2F3FFA1B0F3FFA1B0F3FFA0B0F3FFA0B0F3FF4D49
            BAFF000000050000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000043A8BC9FF3670ACE4050D16230000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000106120E223D8F75E38DD5C1FF3681
            61E4050F0B230000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000024E5195B96A6CCFFF696C
            CFFF696BCEFF696BCEFF686BCEFF4A4C93BA0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000002347AB1DF050D16220000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000106120E21287258BF05100B220000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3Arrows'
        end
        object dxRibbonGalleryItemIconSetsGroup1Item2: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000900000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000020000000500000003000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000030000000B0000001100000013000000130000
            0013000000120000000C00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000100000006120C
            0B34724D43C80F09083400000006000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000007966D60E3110B0A2D0000
            0003000000010000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000000000000A6D4C
            43C39A6A5DFF9A6A5DFF996A5CFF99695BFF99695BFF6D4940C30000000B0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000100000005120D0B34926D61E8D9C7C2FF7F5951E80F0A08350000
            0006000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000009AB7F70FF886056E8110B0A2D0000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000FAE8474FFF4EEEBFFF0E8E4FFF0E8E4FFF0E7
            E4FFEFE7E3FFAC7F70FF00000010000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000100000005120D0B32956F65E7E6D9
            D4FFF0E6E3FFE2D5D1FF815D53EA0F0A08340000000600000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000008AD8173FFE6DBD7FF8862
            58E7120B0A2C0000000300000001000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000000000000EB086
            78FFF5EFECFFEFE6E2FFEFE5E2FFEEE5E1FFF0E8E5FFAE8273FF000000100000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            0005130E0C31967266E7E6DAD6FFF0E7E3FFF0E7E3FFF0E6E3FFE4D8D4FF825E
            54EA100A08330000000500000001000000000000000000000000000000000000
            0000000000000000000000000005000000070000000800000008000000080000
            00080000000FAF8375FFF4EDEAFFE5D9D4FF89635AE7120C0A2C000000030000
            0001000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000DB3897BFFF5F0EEFFF0E7E4FFEFE6E3FFF0E6
            E3FFF1E9E7FFB08577FF0000000F000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000004130E0C2F98766AE6E9DDD8FFF1E8E6FFF0E8
            E5FFF1E8E4FFF0E8E4FFF0E7E4FFE5D9D5FF835F54EA100A0931000000050000
            00010000000000000000000000000000000000000000000000006F4D42BCA477
            69FFA47768FFA37667FFA17566FFA17265FFA07264FFB08677FFF3EBE8FFF0E8
            E4FFE6D9D6FF8A645AE7120C0A2B000000030000000100000000000000000000
            00000000000000000000000000000000000000000000000000000000000CB58C
            7FFFF6F1EFFFF1E9E5FFF1E9E5FFF0E8E5FFF2EBE8FFB3897AFF0000000E0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000004140F0D2D9B7B
            6DE6EADFDAFFF2EAE8FFF2EBE8FFF1EAE7FFF1E9E7FFF1E9E6FFF0E9E6FFF1E8
            E5FFE7DAD6FF866157E9100A0931000000050000000100000000000000000000
            00000000000000000000B08777FFF7F2F0FFF5EFECFFF5EEEBFFF4EEECFFF4EE
            EBFFF4EDEBFFF4EDEAFFF4EDEAFFF1E9E6FFF1E9E6FFE7DBD7FF8C655BE7120C
            0A2B000000030000000100000000000000000000000000000000000000000000
            000000000000000000000000000BB99083FFF7F2F1FFF2EBE7FFF2EAE7FFF1EA
            E7FFF3ECEBFFB58C7EFF0000000D000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000140F0D2BA07E71E5EDE4E0FFF7F3F1FFF7F3F1FFF6F1EFFFF3EB
            E9FFF3ECE9FFF2EBE8FFF4EEEBFFF4EFEDFFF6F0EFFFEADFDCFF886358E9100B
            092F000000030000000000000000000000000000000000000000B48D7DFFF7F4
            F2FFF4EEEBFFF4EEEBFFF4EDEAFFF3EDEAFFF4EDEAFFF3ECE9FFF3ECE9FFF2EB
            E9FFF2EAE7FFF2EAE8FFE7DCD8FF8C665BE7120C0B2A00000002000000000000
            000000000000000000000000000000000007000000090000000A00000011BB94
            87FFF8F4F2FFF4ECE9FFF3ECE9FFF3ECE9FFF4EEECFFB78F82FF000000150000
            000C0000000C0000000900000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000AC8F86E0C6A599FFC5A4
            98FFC5A496FFBC9689FFF7F2F0FFF3EDEAFFF3ECEAFFF3ECEAFFF5F0EDFFB68D
            7FFFC09C90FFBF9B8EFFBF9A8DFFA7867AE40000000700000000000000000000
            00000000000000000000B79284FFF8F4F3FFF5F0EDFFF5EFEDFFF5EFECFFF5EE
            ECFFF5EEEBFFF4EDEBFFF4EEEBFFF4EDEBFFF3EDEAFFF3ECEAFFF3EDEAFFE6D8
            D3FF88685DC70000000400000000000000000000000000000000000000009B76
            69E0B08679FFB08578FFAF8477FFBD988AFFF6F2EFFFF5EEECFFF4EEECFFF4ED
            EBFFF6F0EEFFBA9385FFA97E6FFFA97D6FFFA87D6DFF946E61E4000000060000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000006000000080000000900000010BE9A8DFFF8F3F2FFF5EF
            EDFFF4EFECFFF4EEEBFFF6F0EEFFB89082FF000000130000000B0000000B0000
            0008000000020000000000000000000000000000000000000000BB9688FFF9F6
            F5FFF7F1EFFFF6F0EFFFF6F1EEFFF5F0EEFFF6F0EEFFF6EFEDFFF5EFEDFFF5EF
            EDFFF4EEECFFF4EEEBFFEEE5E2FFA68479E6150F0E2600000001000000000000
            000000000000000000000000000017131127B4968BE5F4EDEAFFF9F6F5FFF8F4
            F2FFF7F3F1FFF6F0EDFFF6F0EDFFF5EFEDFFF6F2F0FFF6F2EFFFF7F1EFFFEFE6
            E4FFA57F74E8140F0D2A00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000008C19D90FFF9F5F3FFF6F1EFFFF6F0EEFFF6F0EEFFF7F2F0FFBB93
            86FF0000000A0000000000000000000000000000000000000000000000000000
            00000000000000000000BF9B8FFFFBF8F7FFFBF8F7FFFBF7F7FFFAF8F7FFFAF7
            F7FFFAF7F7FFF9F7F6FFF8F5F4FFF6F0EEFFF6F0EEFFF0E8E4FFA8867CE61510
            0E26000000020000000000000000000000000000000000000000000000000000
            000217131126B5998EE5F4EDECFFF9F5F4FFF7F2F0FFF7F1EFFFF6F1F0FFF6F0
            EFFFF6F1EFFFF6F0EEFFF1E8E5FFA88378E7150F0E2900000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000007C3A094FFFAF6F5FFF7F3
            F0FFF7F2F0FFF7F1EFFFF8F4F3FFBD978AFF0000000800000000000000000000
            00000000000000000000000000000000000000000000000000008E776FC0CDAF
            A4FFCCAEA4FFCBADA2FFCBACA1FFCAABA0FFC9AA9FFFC8A99EFFF9F7F6FFF7F3
            F0FFF1E9E6FFAA8B7EE615110F25000000020000000000000000000000000000
            0000000000000000000000000000000000000000000217131225B69C91E4F5EE
            ECFFF9F6F5FFF8F3F1FFF8F3F1FFF8F2F0FFF8F2F1FFF1EAE8FFA9887BE71510
            0E28000000030000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000006C6A497FFFAF7F6FFF8F3F2FFF8F3F2FFF7F3F2FFF9F4F4FFBF9A
            8DFF000000070000000000000000000000000000000000000000000000000000
            0000000000000000000000000003000000040000000400000004000000040000
            000400000008CBADA2FFFAF7F7FFF2EBE8FFAD8E84E616110F24000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000117141224B69C93E4F5EFECFFF9F6F6FFF9F5F3FFF8F4
            F2FFF3ECE8FFAD8C81E616110F26000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000005C7A79BFFFAF8F7FFF9F4
            F3FFF9F4F4FFF8F5F3FFF9F6F5FFC19D90FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000004CEB2A7FFF4EDEAFFB090
            86E6161210230000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000011814
            1223B79D94E4F5F0EEFFFAF8F8FFF4ECEAFFB08F85E616111024000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000004CAAA9DFFFBFAF9FFFBFAF9FFFBFAF9FFFBFAF9FFFBF9F8FFC3A0
            93FF000000050000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000004D1B5ABFFAF948AE4161210230000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000118141322B99E96E3F0E7E2FFB093
            85E4171210230000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000298837DB9D1B4A8FFD0B4
            A8FFD0B3A8FFCFB2A6FFCFB1A6FF957D75BA0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000002B9A197DF171211220000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000118141321977F76BF171211220000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3ArrowsGray'
        end
        object dxRibbonGalleryItemIconSetsGroup1Item3: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0003000000060000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000060000000800000009000000090000
            000A0000000A0000000A0000000A0000000B0000000B0000000B0000000B0000
            000C0000000B0000000900000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000304030F2C1C146EC903020F30000000040000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000002869
            51E02C7A5BFF2C795AFF2C775AFF2B7659FF2B7557FF2B7557FF2A7357FF2A72
            55FF2A7255FF297153FF2A6F53FF296F53FF286E52FF246148E4000000060000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000030403102B2423
            84E84C57CFFF1D1A75E803020F2F000000030000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000080000
            000C0000000D0000000D0000000D0000000E0000000E0000000E0000000E0000
            000F0000000F0000000F0000000F0000000E0000000A00000002000000000000
            0000000000000000000000000000050F0B26377D64E594D9C6FF77D8BDFF60D0
            AFFF5DCEACFF5DCEACFF5BCEABFF5BCEABFF59CEABFF59CEAAFF60CFAEFF81D1
            BBFF255B44E80309072A00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002050411292B2889E75868D9FF566BE3FF5364D6FF221F7AE80303
            102E000000030000000000000000000000000000000000000000000000000000
            00000000000000000000193C79BF2253A8FF2153A8FF2152A7FF2151A7FF2051
            A7FF2051A6FF2050A6FF2050A6FF1F4FA6FF1F4FA5FF1F4EA5FF1F4EA5FF1F4E
            A5FF163675C10000000900000000000000000000000000000000000000000000
            0002060F0C25387F64E496DBC7FF6CD5B5FF51CBA6FF4EC9A3FF4DC8A2FF4DC8
            A3FF4CC9A2FF55CCA8FF85D3BCFF275C47E7030A072900000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002050512282E2D8FE76172DDFF5D72
            E5FF5A6FE4FF5A6FE4FF5969DAFF23227EE80403102D00000003000000000000
            00000000000000000000000000000000000000000000000000003970B9FF98DF
            F9FF7CD5F7FF7BD3F7FF79D1F6FF78D0F5FF76CFF5FF74CDF5FF73CCF4FF73CB
            F3FF71CAF3FF70C9F2FF6FC8F2FF6DC7F2FF3060B0FF0000000D000000000000
            0000000000000000000000000000000000000000000106100C24398368E498DE
            CAFF6FD7B8FF55CCA8FF51CBA5FF51CAA5FF59CEABFF89D5BFFF296349E7030B
            0727000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000020606
            1326343398E6697AE0FF657BE7FF6277E6FF6175E7FF5F74E6FF5E73E6FF5D6E
            DBFF272482E70403112C00000003000000000000000000000000000000000000
            000000000000000000003C77BEFFA1E5FBFF73D6F9FF72D4F8FF70D3F8FF6ED2
            F7FF6DD0F7FF6BCEF6FF69CDF5FF67CBF5FF66C9F4FF64C8F3FF63C6F3FF74CE
            F5FF3466B3FF0000000C00000000000000000000000000000000000000000000
            0000000000000000000106100C233A846AE49CDECBFF72D8BAFF57CDAAFF5FD1
            AFFF8ED7C2FF29674EE6030B0826000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000001070614243B3B9DE66F81E3FF6B81E9FF687EE9FF677D
            E9FF667BE8FF647AE8FF6379E8FF6378E7FF6274DEFF292984E70504122B0000
            00020000000000000000000000000000000000000000000000003F7DC2FFA6EC
            FDFFA6EBFDFFA4E9FDFFA4E9FCFFA2E8FCFFA1E7FCFFA1E5FBFF9FE5FBFF9EE4
            FBFF9CE3FAFF9BE2FAFF9BE1F9FF99DFF9FF366CB8FF0000000A000000000000
            0000000000000000000000000000000000000000000000000000000000010611
            0D223D886EE49EDFCDFF7EDCC1FF93D7C4FF2B6A51E6030C0824000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000080816253F40A1E58293
            E6FF8B9EEFFF8A9DEFFF889BEEFF879AEEFF8698EDFF8497EEFF8195EDFF7F93
            ECFF7E91ECFF7282E0FF2D2B8CE70504122A0000000200000000000000000000
            000000000000000000002D6594C13E87C8FF3E87C7FF3E86C7FF3E85C7FF3D85
            C6FF3C84C6FF3C84C5FF3C83C5FF3B82C5FF3B81C4FF3B81C4FF3B80C4FF3A7F
            C3FF2B5D91C30000000600000000000000000000000000000000000000000000
            00000000000000000000000000000000000106110D223D8A6FE396D5C3FF2E70
            56E4040D09230000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000005A5AB4E26567CCFF6566CCFF6566CCFF6566CCFF6566CCFF6566
            CCFF6465CBFF6465CBFF6465CBFF6465CBFF6364CAFF6364CAFF6363CAFF5556
            B1E3000000030000000000000000000000000000000000000000000000030000
            0005000000060000000600000006000000060000000600000007000000070000
            0007000000070000000800000008000000070000000500000002000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000106120E21276D55BF040D09220000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000020000
            0002000000020000000300000003000000030000000300000003000000040000
            0004000000040000000400000004000000030000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3Triangles'
        end
        object dxRibbonGalleryItemIconSetsGroup1Item4: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000900000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000002000000060000000A00000007000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00030000000B00000011000000130000001300000013000000120000000C0000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000060403
            1034181366C803020D3400000006000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002000000090000000E0000000F0000000F00000010000000100000
            00100000001000000010000000100000000D0000000400000000000000000000
            0000000000000000000000000000000000000000000000000001000000090410
            31710E3B8DE6031133770000000A000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000A15432FC31F5E43FF1F5D42FF1F5D
            41FF1E5C42FF1F5C41FF15422FC30000000B0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000010000000504031134252388E84450CAFF1A1872E803020E350000
            0006000000010000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000005193973B92450A7FF2450
            A7FF2350A5FF234FA4FF234FA6FF234DA4FF234CA4FF234CA2FF234CA1FF234B
            A1FF0000000D0000000000000000000000000000000000000000000000000000
            00000000000100000008041132712B61ACFF59ACE4FF2C63AEFF0411367A0000
            0009000000020000000000000001000000030000000600000002000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000F2B7457FF72D7BAFF54CAA6FF52CAA5FF52C9A4FF52C9A4FF2A7154FF0000
            0010000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000505041132282389E74D5C
            D6FF4658DDFF4858D2FF1C1B75EA03020E340000000600000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000203060B1D2B5390D1AACFEBFFB0E4FAFF7ECDF3FF70C5F1FF6EC4
            F1FF6CC3F1FF6BC1F0FF68BFF0FF2A58AEFF0000000F00000000000000000000
            00000000000000000000000000000000000100000008041234703067AFFF5EBA
            EEFF4DAEEAFF5AB6ECFF2F68B1FF041237790000000900000001000000030102
            081E0A3073BE0000000900000000000000000000000000000000000000000000
            00000000000000000000000000000000000E2C7759FF76D8BCFF46C59DFF46C5
            9DFF45C49CFF54CBA7FF2A7456FF000000100000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            0005050411312B288BE75261D8FF495CDFFF4659DEFF475BDFFF4C5DD5FF1C1B
            75EA03020E330000000500000001000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000303060B1E2D56
            93D2A0CDEAFF7FD1F5FF59BBF1FF56B9EDFF54B8EDFF52B6EDFF70C5F1FF2A5B
            B1FF0000000E0000000000000000000000000000000000000000000000000000
            0005091E406D336DB3FF67C2F2FF52B6EDFF50B3ECFF4EB2ECFF5FBBEFFF336B
            B2FF041337780000000B0103081E0C2A6FD41245A2FF0000000C000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000D2C795BFF79DABEFF48C59FFF47C69EFF47C69EFF58CCA9FF2B7659FF0000
            000F000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000040504122F2D298EE65868DAFF4E61E1FF4B5E
            DFFF4A5DDFFF4A5DDFFF4B5EDFFF5160D6FF1E1C77EA03020E31000000050000
            0001000000000000000000000000000000000000000000000000000000000000
            000000000000000000010000000B0C204C905B8FC7FF71CEF5FF60C5F3FF5FC1
            F2FF5CC0F1FF5ABFF1FF78CDF3FF2C5DB2FF0000000D00000000000000000000
            000000000000000000000000000000000007154E9DEC81C9EEFF5FC2F1FF5BBF
            F1FF59BBF1FF56B9EDFF54B8EDFF65C0F0FF356EB4FF09224A830F2F74D456A2
            DAFF1448A4FF0000000C00000000000000000000000000000000000000000000
            00000000000000000000000000000000000C2D7C5EFF7CDBC1FF4AC7A1FF4AC7
            A0FF49C7A0FF5BCEACFF2C795BFF0000000E0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000040505122D312D
            8FE65E6EDCFF5467E3FF5064E1FF4F63E1FF4E63E1FF4E62E1FF4D61E0FF4F63
            E1FF5464D8FF1E1D79E903020E31000000050000000100000000000000000000
            00000000000000000000000000000000000000000001000000080C2048845C8F
            C7FF7BD7F8FF6BCFF7FF69CDF4FF67C9F4FF64C9F3FF63C7F3FF7ED3F5FF2E60
            B4FF0000000C0000000000000000000000000000000000000000000000000000
            00040B274D795494CFFF85D5F6FF62C7F3FF60C5F3FF5FC1F2FF5CC0F1FF5ABF
            F1FF6BC7F1FF4086CAFF5BA8DBFF72C7F2FF154CA6FF0000000B000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000B2E7F60FF7FDBC1FF4CC8A2FF4CC8A1FF4BC8A1FF5ECFAEFF2C7C5EFF0000
            000D000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000605132B353192E57B8BE3FF8697EDFF8596EDFF7789EBFF5468
            E2FF5467E2FF5367E3FF6679E6FF7484E9FF7F8FECFF7381DFFF25237AE90303
            0E2F000000030000000000000000000000000000000000000000000000000000
            0001000000070D214A836095C9FF86E0FAFF75D9F9FF73D6F8FF70D5F8FF6ED2
            F8FF6DD1F7FF6ACEF4FF87D9F7FF2F65B6FF0000000B00000000000000000000
            000000000000000000000000000000000001000000060D2C54825B9CD4FF88DA
            F9FF69CDF4FF67C9F4FF64C9F3FF63C7F3FF60C5F2FF6FCAF4FF62C3F2FF7ACE
            F5FF164FA8FF0000000A00000000000000000000000000000000000000000000
            000000000007000000090000000A000000112F8363FF82DDC4FF4EC9A4FF4DC9
            A3FF4DC9A3FF62D0B0FF2E7F60FF000000150000000C0000000C000000090000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000005354AEE06162C7FF6161
            C7FF6061C7FF453EB1FF7C8EEBFF586DE4FF576CE4FF576BE4FF6B7EE8FF3C34
            AAFF5D5DC3FF5D5CC3FF5C5CC3FF5050ADE40000000700000000000000000000
            0000000000000000000000000001000000060D244D826399CEFF8DE6FDFF7FE0
            FDFF7CDFFDFF7ADEFAFF79DCFAFF77D9F9FFA1E6FCFFA3E5FBFF98E2FBFF3167
            B8FF0000000A0000000000000000000000000000000000000000000000000000
            000000000001000000060D2D54815D9FD5FF8DDFFAFF6ED2F8FF6DD1F7FF6ACE
            F4FF69CDF4FF67C9F4FF64C8F3FF81D4F5FF1855ACFF00000009000000000000
            000000000000000000000000000000000000206449E0247453FF247253FF2371
            52FF308566FF67D4B5FF4FCBA6FF4FCBA5FF4FCAA5FF65D3B2FF2F8263FF236C
            4EFF226B4EFF226A4EFF1E5E44E4000000060000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000060000000800000009000000104843B4FF8193ECFF5D72
            E5FF5C72E5FF5C71E5FF7084E8FF3F38ADFF000000130000000B0000000B0000
            0008000000020000000000000000000000000000000000000000000000030E26
            4F806F9FD0FF97EDFEFF86E6FFFF84E6FEFF82E5FDFF81E5FDFF80E2FDFFABEC
            FEFF78A7D6FFB6D9EEFFC5F2FDFF336DBBFF0000000900000000000000000000
            0000000000000000000000000000000000000000000000000001000000050E2E
            568060A2D6FF93E2FBFF74D8F9FF73D6F9FF70D4F8FF6ED4F7FF6DD1F7FF88DB
            F9FF1A58AEFF0000000900000000000000000000000000000000000000000000
            000006100D2739866BE592DBC6FF8AE0C9FF70D8B9FF6BD5B7FF52CCA7FF51CC
            A7FF51CBA7FF68D4B6FF67D4B4FF6AD4B6FF78D1B6FF2E6F56E8040D092A0000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000084B46B8FF8899EEFF6378E7FF6177E6FF6176E6FF7689EAFF413B
            AFFF0000000A0000000000000000000000000000000000000000000000000000
            00000000000000000000000000043574B9F1D1F3FCFFA9F1FFFF89EBFFFF89EB
            FFFF88EBFEFF87E9FFFFB2F0FEFF74A5D7FF162F527B34629DD1BBDCF1FF346F
            BDFF000000090000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000060B2953895A9DD2FF8BE4FBFF7ADE
            FAFF78DCF9FF77DBF9FF74D8F9FF8FE0FAFF1C5EB2FF00000008000000000000
            0000000000000000000000000000000000000000000206110D2639886DE591DC
            C6FF77D9BEFF59CFACFF54CEA9FF53CDA9FF54CDA8FF52CDA8FF5ACFACFF79D1
            B9FF32715AE7050D0A2900000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000074F4ABAFF8C9DEEFF677D
            E8FF677CE8FF667BE8FF7C8FECFF443EB2FF0000000800000000000000000000
            0000000000000000000000000000000000000000000000000000000000021630
            4B677AAEDCFFD6F9FFFFA9F1FFFF8AEBFFFF89EBFFFFB3F3FFFF76A8D9FF142D
            4C6F0000000603070B1734669DD03675C1FF0000000700000000000000000000
            0000000000000000000000000000000000000000000000000000000000010105
            0A161C4D8CD081CCEDFF88E6FEFF81E4FDFF7FE4FDFF7EE0FAFF7CDFFAFF97E5
            FBFF1C61B5FF0000000700000000000000000000000000000000000000000000
            0000000000000000000206110D253C8B6FE493DDC8FF79DABFFF5AD1AEFF55CF
            AAFF55CEAAFF5CD0AEFF7CD3BBFF34775BE7050E0A2800000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000006514EBCFF8FA2F0FF6C81EAFF6C80EAFF6B80EAFF8194EEFF4742
            B5FF000000070000000000000000000000000000000000000000000000000000
            00000000000000000000000000010000000316314C667BB0DDFFD5F8FEFFAFF2
            FFFFB7F4FFFF77ABDBFF152F4E6D00000004000000010000000203070B172755
            8BBA000000040000000000000000000000000000000000000000000000000000
            0000000000000000000101050A141C5290CF96D3EEFFB7F4FFFFB6F3FFFFB6F2
            FFFFB5F2FEFFB4F1FEFFB2F1FEFFB1F0FEFF1E64B8FF00000006000000000000
            0000000000000000000000000000000000000000000000000000000000010611
            0D243D8B71E495DDCAFF7BDCC0FF5CD1AEFF5FD1B0FF80D4BCFF337A5DE6050E
            0A26000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000055451BFFF94A6F1FF6F85
            EBFF6F85EBFF6E84EBFF8499EFFF4A45B7FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000317324C6678AFDBFDCDEBF8FF7BAFDCFF16314F6C000000030000
            0001000000000000000000000001000000020000000100000000000000000000
            0000000000000000000000000000000000000000000000000002276291B6378C
            CDFF378BCCFF378ACBFF3689CBFF3688CBFF3587CAFF3586CAFF3485C8FF3484
            C7FF3383C7FF0000000400000000000000000000000000000000000000000000
            00000000000000000000000000000000000106120E233E8E72E495DDCBFF83DF
            C5FF84D7BFFF347D61E6050F0B24000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000045855C2FFA2B2F3FFA1B0F3FFA1B0F3FFA0B0F3FFA0B0F3FF4D49
            BAFF000000050000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000216314B613474
            B2DF1633506B0000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000002000000030000000300000003000000040000
            0004000000040000000400000004000000040000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000106120E223D8F75E38DD5C1FF368161E4050F0B23000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000024E5195B96A6CCFFF696C
            CFFF696BCEFF696BCEFF686BCEFF4A4C93BA0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000020000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000106120E212872
            58BF05100B220000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '4Arrows'
        end
        object dxRibbonGalleryItemIconSetsGroup1Item5: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000900000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000002000000060000000A00000007000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00030000000B00000011000000130000001300000013000000120000000C0000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000100000006120C
            0B34724D43C80F09083400000006000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002000000090000000E0000000F0000000F00000010000000100000
            00100000001000000010000000100000000D0000000400000000000000000000
            000000000000000000000000000000000000000000000000000100000009311F
            1B718C6257E634201B770000000A000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000A6D4C43C39A6A5DFF9A6A5DFF996A
            5CFF99695BFF99695BFF6D4940C30000000B0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000100000005120D0B34926D61E8D9C7C2FF7F5951E80F0A08350000
            0006000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000568483EB995665AFF9465
            59FF946558FF936457FF926356FF926255FF916154FF916154FF906053FF8F60
            53FF0000000D0000000000000000000000000000000000000000000000000000
            0000000000010000000832211C71AE8E85FFE9DEDAFFB09188FF36221D7A0000
            0009000000020000000000000001000000030000000600000002000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000FAE8474FFF4EEEBFFF0E8E4FFF0E8E4FFF0E7E4FFEFE7E3FFAC7F70FF0000
            0010000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000100000005120D0B32956F65E7E6D9
            D4FFF0E6E3FFE2D5D1FF815D53EA0F0A08340000000600000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000020A07061D86655BD1E8DCD8FFFAF6F5FFF5EFECFFF3EDEAFFF3ED
            EAFFF3ECE9FFF3ECEAFFF2ECE9FF9D6E60FF0000000F00000000000000000000
            0000000000000000000000000000000000010000000834231E70B19189FFF2EB
            E7FFEFE8E4FFF1EAE6FFB2948CFF36231E790000000900000001000000030805
            041E715048BE0000000900000000000000000000000000000000000000000000
            00000000000000000000000000000000000EB08678FFF5EFECFFEFE6E2FFEFE5
            E2FFEEE5E1FFF0E8E5FFAE8273FF000000100000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            0005130E0C31967266E7E6DAD6FFF0E7E3FFF0E7E3FFF0E6E3FFE4D8D4FF825E
            54EA100A08330000000500000001000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000030A07061E8867
            5BD2E7DBD7FFF4EEEBFFF0E7E3FFF0E8E4FFF0E7E3FFEFE7E3FFF4EDEAFF9F71
            63FF0000000E0000000000000000000000000000000000000000000000000000
            000540312C6DB4958CFFF2EBE8FFEFE8E4FFEFE7E4FFEFE7E3FFF2EBE8FFB495
            8DFF37241F780000000B0805041E6F4C43D4A07366FF0000000C000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000DB3897BFFF5F0EEFFF0E7E4FFEFE6E3FFF0E6E3FFF1E9E7FFB08577FF0000
            000F000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000004130E0C2F98766AE6E9DDD8FFF1E8E6FFF0E8
            E5FFF1E8E4FFF0E8E4FFF0E7E4FFE5D9D5FF835F54EA100A0931000000050000
            0001000000000000000000000000000000000000000000000000000000000000
            000000000000000000010000000B432B2490BEA49CFFF2ECE8FFF0E8E5FFF0E8
            E5FFF0E8E4FFF0E8E4FFF4EDEBFFA17467FF0000000D00000000000000000000
            0000000000000000000000000000000000079F796EECEEE4E2FFF1E9E6FFF1E9
            E5FFF1E9E6FFF0E9E5FFF0E8E5FFF3ECE8FFB6988FFF4A363183745147D4DCCE
            C9FFA37669FF0000000C00000000000000000000000000000000000000000000
            00000000000000000000000000000000000CB58C7FFFF6F1EFFFF1E9E5FFF1E9
            E5FFF0E8E5FFF2EBE8FFB3897AFF0000000E0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000004140F0D2D9B7B
            6DE6EADFDAFFF2EAE8FFF2EBE8FFF1EAE7FFF1E9E7FFF1E9E6FFF0E9E6FFF1E8
            E5FFE7DAD6FF866157E9100A0931000000050000000100000000000000000000
            0000000000000000000000000000000000000000000100000008412A2484BDA1
            9BFFF3EDEAFFF1EAE6FFF1E9E6FFF1E9E6FFF1EAE6FFF0E8E6FFF5EFECFFA478
            6AFF0000000C0000000000000000000000000000000000000000000000000000
            00044D3C3779CFB6AFFFF5EFEDFFF1EAE6FFF2EAE6FFF1EAE6FFF1E9E6FFF2EA
            E6FFF3EDEAFFCBB0A8FFDECFCAFFF5EFECFFA57A6DFF0000000B000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000BB99083FFF7F2F1FFF2EBE7FFF2EAE7FFF1EAE7FFF3ECEBFFB58C7EFF0000
            000D000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000140F0D2BA07E71E5EDE4E0FFF7F3F1FFF7F3F1FFF6F1EFFFF3EB
            E9FFF3ECE9FFF2EBE8FFF4EEEBFFF4EFEDFFF6F0EFFFEADFDCFF886358E9100B
            092F000000030000000000000000000000000000000000000000000000000000
            000100000007422D2783BFA59DFFF4EEEBFFF2EBE8FFF2EAE8FFF2EBE8FFF2EA
            E7FFF2EAE7FFF2EAE6FFF5EFECFFA67B6EFF0000000B00000000000000000000
            0000000000000000000000000000000000010000000654413C82D3BCB5FFF6F0
            EEFFF2EBE8FFF2EBE7FFF3EAE7FFF2EAE7FFF2EBE8FFF4EDEBFFF3ECE8FFF5EF
            EDFFA97E70FF0000000A00000000000000000000000000000000000000000000
            000000000007000000090000000A00000011BB9487FFF8F4F2FFF4ECE9FFF3EC
            E9FFF3ECE9FFF4EEECFFB78F82FF000000150000000C0000000C000000090000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000AC8F86E0C6A599FFC5A4
            98FFC5A496FFBC9689FFF7F2F0FFF3EDEAFFF3ECEAFFF3ECEAFFF5F0EDFFB68D
            7FFFC09C90FFBF9B8EFFBF9A8DFFA7867AE40000000700000000000000000000
            000000000000000000000000000100000006452F2982C3A8A0FFF5EEEDFFF3EC
            E9FFF3ECE9FFF3ECE9FFF3ECE9FFF2ECE9FFF7F3EFFFF7F3F1FFF6F2EFFFAA80
            72FF0000000A0000000000000000000000000000000000000000000000000000
            0000000000010000000655433E81D4BEB7FFF6F0EFFFF3ECE9FFF3ECE9FFF3EC
            E9FFF3ECE9FFF3ECE9FFF3ECE9FFF5F1EFFFAB8175FF00000009000000000000
            0000000000000000000000000000000000009B7669E0B08679FFB08578FFAF84
            77FFBD988AFFF6F2EFFFF5EEECFFF4EEECFFF4EDEBFFF6F0EEFFBA9385FFA97E
            6FFFA97D6FFFA87D6DFF946E61E4000000060000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000006000000080000000900000010BE9A8DFFF8F3F2FFF5EF
            EDFFF4EFECFFF4EEEBFFF6F0EEFFB89082FF000000130000000B0000000B0000
            0008000000020000000000000000000000000000000000000000000000034733
            2C80C6ADA6FFF5F0EEFFF4EDEBFFF4EDEBFFF4EDEBFFF3EDEBFFF4EDEAFFF8F4
            F2FFCDB5ADFFEBE0DDFFFBF8F7FFAC8377FF0000000900000000000000000000
            0000000000000000000000000000000000000000000000000001000000055644
            3F80D6C0B9FFF6F2EFFFF4EEEBFFF4EDEBFFF4EEEAFFF4EDEAFFF4EDEAFFF7F1
            EFFFAF8579FF0000000900000000000000000000000000000000000000000000
            000017131127B4968BE5F4EDEAFFF9F6F5FFF8F4F2FFF7F3F1FFF6F0EDFFF6F0
            EDFFF5EFEDFFF6F2F0FFF6F2EFFFF7F1EFFFEFE6E4FFA57F74E8140F0D2A0000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000008C19D90FFF9F5F3FFF6F1EFFFF6F0EEFFF6F0EEFFF7F2F0FFBB93
            86FF0000000A0000000000000000000000000000000000000000000000000000
            0000000000000000000000000004B08D81F1F8F5F4FFF8F4F3FFF5EFECFFF4EF
            ECFFF5EEECFFF5EEEBFFF8F5F3FFCDB4ADFF4C3A347B94746BD1EDE3E0FFB088
            7CFF000000090000000000000000000000000000000000000000000000000000
            00000000000000000000000000010000000655403B89D0B9B2FFF5F0EEFFF4EE
            ECFFF4EEECFFF5EFEBFFF5EEECFFF7F2F1FFB1897DFF00000008000000000000
            0000000000000000000000000000000000000000000217131126B5998EE5F4ED
            ECFFF9F5F4FFF7F2F0FFF7F1EFFFF6F1F0FFF6F0EFFFF6F1EFFFF6F0EEFFF1E8
            E5FFA88378E7150F0E2900000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000007C3A094FFFAF6F5FFF7F3
            F0FFF7F2F0FFF7F1EFFFF8F4F3FFBD978AFF0000000800000000000000000000
            000000000000000000000000000000000000000000000000000000000002473A
            3667D4BEB6FFFCFAFAFFF8F4F3FFF5F0EDFFF5EFEDFFF9F6F3FFD0B8B0FF4738
            326F000000060B08081794786DD0B38C80FF0000000700000000000000000000
            0000000000000000000000000000000000000000000000000000000000010A08
            0716907168D0E8DBD8FFF6F0EEFFF5F0EDFFF6F0EDFFF6EFEDFFF5F0EDFFF8F3
            F2FFB48E82FF0000000700000000000000000000000000000000000000000000
            0000000000000000000217131225B69C91E4F5EEECFFF9F6F5FFF8F3F1FFF8F3
            F1FFF8F2F0FFF8F2F1FFF1EAE8FFA9887BE715100E2800000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000006C6A497FFFAF7F6FFF8F3F2FFF8F3F2FFF7F3F2FFF9F4F4FFBF9A
            8DFF000000070000000000000000000000000000000000000000000000000000
            000000000000000000000000000100000003483B3666D6C0B8FFFBFAF9FFFAF5
            F4FFF9F7F6FFD3BBB4FF493A356D0000000400000001000000020B0808178368
            5FBA000000040000000000000000000000000000000000000000000000000000
            000000000000000000010B08081491766DCFEBE1DDFFFAF8F5FFFAF8F5FFFAF8
            F5FFFAF8F5FFFAF7F5FFFAF7F5FFFAF8F5FFB89286FF00000006000000000000
            0000000000000000000000000000000000000000000000000000000000011714
            1224B69C93E4F5EFECFFF9F6F6FFF9F5F3FFF8F4F2FFF3ECE8FFAD8C81E61611
            0F26000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000005C7A79BFFFAF8F7FFF9F4
            F3FFF9F4F4FFF8F5F3FFF9F6F5FFC19D90FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000003493C3766D4BEB9FDF6F0EEFFD5BFB8FF4A3C376C000000030000
            0001000000000000000000000001000000020000000100000000000000000000
            00000000000000000000000000000000000000000000000000028F7971B6C9AB
            A0FFC9AA9FFFC8A99FFFC8A99EFFC7A89DFFC7A79DFFC6A79CFFC5A59BFFC4A5
            9AFFC4A499FF0000000400000000000000000000000000000000000000000000
            00000000000000000000000000000000000118141223B79D94E4F5F0EEFFFAF8
            F8FFF4ECEAFFB08F85E616111024000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000004CAAA9DFFFBFAF9FFFBFAF9FFFBFAF9FFFBFAF9FFFBF9F8FFC3A0
            93FF000000050000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000002473B3761AA8C
            81DF4C3E396B0000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000002000000030000000300000003000000040000
            0004000000040000000400000004000000040000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000118141322B99E96E3F0E7E2FFB09385E417121023000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000298837DB9D1B4A8FFD0B4
            A8FFD0B3A8FFCFB2A6FFCFB1A6FF957D75BA0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000020000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000118141321977F
            76BF171211220000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '4ArrowsGray'
        end
        object dxRibbonGalleryItemIconSetsGroup1Item6: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000900000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000002000000050000
            0003000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0002000000060000000A00000007000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000030000000B000000110000
            00130000001300000013000000120000000C0000000300000000000000000000
            0000000000000000000000000000000000000000000000000001000000060403
            1034181366C803020D3400000006000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002000000090000000E0000000F0000000F00000010000000100000
            00100000001000000010000000100000000D0000000400000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000071B4796E30206112D0000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000100000009041031710E3B8DE6031133770000
            000A000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000A15432FC31F5E43FF1F5D42FF1F5D41FF1E5C42FF1F5C41FF1542
            2FC30000000B0000000000000000000000000000000000000000000000000000
            0000000000010000000504031134252388E84450CAFF1A1872E803020E350000
            0006000000010000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000005193973B92450A7FF2450
            A7FF2350A5FF234FA4FF234FA6FF234DA4FF234CA4FF234CA2FF234CA1FF234B
            A1FF0000000D0000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000091F53AAFF193F
            86E80207112D0000000300000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000080411
            32712B61ACFF59ACE4FF2C63AEFF0411367A0000000900000002000000000000
            0001000000030000000600000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000F2B7457FF72D7BAFF54CA
            A6FF52CAA5FF52C9A4FF52C9A4FF2A7154FF0000001000000000000000000000
            0000000000000000000000000000000000010000000505041132282389E74D5C
            D6FF4658DDFF4858D2FF1C1B75EA03020E340000000600000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000203060B1D2B5390D1AACFEBFFB0E4FAFF7ECDF3FF70C5F1FF6EC4
            F1FF6CC3F1FF6BC1F0FF68BFF0FF2A58AEFF0000000F00000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000082056ABFF64AFE2FF183E85E70207122C000000030000
            0001000000000000000000000000000000000000000000000000000000000000
            00000000000100000008041234703067AFFF5EBAEEFF4DAEEAFF5AB6ECFF2F68
            B1FF041237790000000900000001000000030102081E0A3073BE000000090000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000E2C7759FF76D8BCFF46C59DFF46C59DFF45C49CFF54CBA7FF2A74
            56FF000000100000000000000000000000000000000000000000000000010000
            0005050411312B288BE75261D8FF495CDFFF4659DEFF475BDFFF4C5DD5FF1C1B
            75EA03020E330000000500000001000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000303060B1E2D56
            93D2A0CDEAFF7FD1F5FF59BBF1FF56B9EDFF54B8EDFF52B6EDFF70C5F1FF2A5B
            B1FF0000000E0000000000000000000000000000000000000000000000000000
            000500000007000000080000000800000008000000080000000F2157ADFF73C3
            EFFF54A7DFFF183F85E70207122C000000030000000100000000000000000000
            00000000000000000000000000000000000000000005091E406D336DB3FF67C2
            F2FF52B6EDFF50B3ECFF4EB2ECFF5FBBEFFF336BB2FF041337780000000B0103
            081E0C2A6FD41245A2FF0000000C000000000000000000000000000000000000
            0000000000000000000000000000000000000000000D2C795BFF79DABEFF48C5
            9FFF47C69EFF47C69EFF58CCA9FF2B7659FF0000000F00000000000000000000
            00000000000000000000000000040504122F2D298EE65868DAFF4E61E1FF4B5E
            DFFF4A5DDFFF4A5DDFFF4B5EDFFF5160D6FF1E1C77EA03020E31000000050000
            0001000000000000000000000000000000000000000000000000000000000000
            000000000000000000010000000B0C204C905B8FC7FF71CEF5FF60C5F3FF5FC1
            F2FF5CC0F1FF5ABFF1FF78CDF3FF2C5DB2FF0000000D00000000000000000000
            000000000000000000000000000012346CBC1A4BA0FF194A9EFF19499DFF1949
            9EFF19489DFF19479CFF2159AEFF67BDEEFF57B3EBFF58AAE1FF184088E70207
            122B000000030000000100000000000000000000000000000000000000000000
            000000000007154E9DEC81C9EEFF5FC2F1FF5BBFF1FF59BBF1FF56B9EDFF54B8
            EDFF65C0F0FF356EB4FF09224A830F2F74D456A2DAFF1448A4FF0000000C0000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000C2D7C5EFF7CDBC1FF4AC7A1FF4AC7A0FF49C7A0FF5BCEACFF2C79
            5BFF0000000E00000000000000000000000000000000000000040505122D312D
            8FE65E6EDCFF5467E3FF5064E1FF4F63E1FF4E63E1FF4E62E1FF4D61E0FF4F63
            E1FF5464D8FF1E1D79E903020E31000000050000000100000000000000000000
            00000000000000000000000000000000000000000001000000080C2048845C8F
            C7FF7BD7F8FF6BCFF7FF69CDF4FF67C9F4FF64C9F3FF63C7F3FF7ED3F5FF2E60
            B4FF0000000C0000000000000000000000000000000000000000000000002562
            AEFF89D1F4FF76C7F2FF74C7F0FF72C4F1FF72C4F0FF70C3F0FF6FC2F0FF6DC1
            F0FF5BB7ECFF5CB7EDFF5DADE2FF194089E70207122B00000003000000010000
            000000000000000000000000000000000000000000040B274D795494CFFF85D5
            F6FF62C7F3FF60C5F3FF5FC1F2FF5CC0F1FF5ABFF1FF6BC7F1FF4086CAFF5BA8
            DBFF72C7F2FF154CA6FF0000000B000000000000000000000000000000000000
            0000000000000000000000000000000000000000000B2E7F60FF7FDBC1FF4CC8
            A2FF4CC8A1FF4BC8A1FF5ECFAEFF2C7C5EFF0000000D00000000000000000000
            0000000000000605132B353192E57B8BE3FF8697EDFF8596EDFF7789EBFF5468
            E2FF5467E2FF5367E3FF6679E6FF7484E9FF7F8FECFF7381DFFF25237AE90303
            0E2F000000030000000000000000000000000000000000000000000000000000
            0001000000070D214A836095C9FF86E0FAFF75D9F9FF73D6F8FF70D5F8FF6ED2
            F8FF6DD1F7FF6ACEF4FF87D9F7FF2F65B6FF0000000B00000000000000000000
            00000000000000000000000000002867B2FF8FD5F5FF69C3F1FF68C2F0FF67C1
            F0FF65C0EFFF64C0EFFF63BFEFFF62BEEEFF60BCEFFF5FBBEEFF61BCEEFF61B1
            E3FF1B448AE70207122A00000002000000000000000000000000000000000000
            000000000001000000060D2C54825B9CD4FF88DAF9FF69CDF4FF67C9F4FF64C9
            F3FF63C7F3FF60C5F2FF6FCAF4FF62C3F2FF7ACEF5FF164FA8FF0000000A0000
            0000000000000000000000000000000000000000000000000007000000090000
            000A000000112F8363FF82DDC4FF4EC9A4FF4DC9A3FF4DC9A3FF62D0B0FF2E7F
            60FF000000150000000C0000000C00000009000000025354AEE06162C7FF6161
            C7FF6061C7FF453EB1FF7C8EEBFF586DE4FF576CE4FF576BE4FF6B7EE8FF3C34
            AAFF5D5DC3FF5D5CC3FF5C5CC3FF5050ADE40000000700000000000000000000
            0000000000000000000000000001000000060D244D826399CEFF8DE6FDFF7FE0
            FDFF7CDFFDFF7ADEFAFF79DCFAFF77D9F9FFA1E6FCFFA3E5FBFF98E2FBFF3167
            B8FF0000000A000000000000000000000000000000000000000000000000296B
            B4FF95DAF7FF6FC9F3FF6EC8F1FF6EC7F3FF6CC5F1FF6AC4F0FF6AC4F0FF68C3
            F0FF67C1F0FF66C0EFFF64BFF0FF69C2F0FF6FB4E3FF1B4586C7000000040000
            0000000000000000000000000000000000000000000000000001000000060D2D
            54815D9FD5FF8DDFFAFF6ED2F8FF6DD1F7FF6ACEF4FF69CDF4FF67C9F4FF64C8
            F3FF81D4F5FF1855ACFF00000009000000000000000000000000000000000000
            000000000000206449E0247453FF247253FF237152FF308566FF67D4B5FF4FCB
            A6FF4FCBA5FF4FCAA5FF65D3B2FF2F8263FF236C4EFF226B4EFF226A4EFF1E5E
            44E400000006000000060000000800000009000000104843B4FF8193ECFF5D72
            E5FF5C72E5FF5C71E5FF7084E8FF3F38ADFF000000130000000B0000000B0000
            0008000000020000000000000000000000000000000000000000000000030E26
            4F806F9FD0FF97EDFEFF86E6FFFF84E6FEFF82E5FDFF81E5FDFF80E2FDFFABEC
            FEFF78A7D6FFB6D9EEFFC5F2FDFF336DBBFF0000000900000000000000000000
            00000000000000000000000000002D71B8FF9CDEF8FF76CEF4FF75CDF4FF74CD
            F4FF73CBF4FF71CBF3FF70C9F3FF6FC8F1FF6EC8F3FF6CC7F1FF6FC6F1FF7FC6
            ECFF2B5EA2E6040B142600000001000000000000000000000000000000000000
            0000000000000000000000000001000000050E2E568060A2D6FF93E2FBFF74D8
            F9FF73D6F9FF70D4F8FF6ED4F7FF6DD1F7FF88DBF9FF1A58AEFF000000090000
            0000000000000000000000000000000000000000000006100D2739866BE592DB
            C6FF8AE0C9FF70D8B9FF6BD5B7FF52CCA7FF51CCA7FF51CBA7FF68D4B6FF67D4
            B4FF6AD4B6FF78D1B6FF2E6F56E8040D092A0000000300000000000000000000
            0000000000084B46B8FF8899EEFF6378E7FF6177E6FF6176E6FF7689EAFF413B
            AFFF0000000A0000000000000000000000000000000000000000000000000000
            00000000000000000000000000043574B9F1D1F3FCFFA9F1FFFF89EBFFFF89EB
            FFFF88EBFEFF87E9FFFFB2F0FEFF74A5D7FF162F527B34629DD1BBDCF1FF346F
            BDFF000000090000000000000000000000000000000000000000000000002F76
            BBFFAFE7FBFFAEE6FAFFADE5FAFFACE5F9FFABE4F9FFAAE2F9FFA8E2F9FF99DB
            F8FF75CDF4FF77CEF4FF87CAEFFF2C61A6E6040B142600000002000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000060B2953895A9DD2FF8BE4FBFF7ADEFAFF78DCF9FF77DBF9FF74D8
            F9FF8FE0FAFF1C5EB2FF00000008000000000000000000000000000000000000
            0000000000000000000206110D2639886DE591DCC6FF77D9BEFF59CFACFF54CE
            A9FF53CDA9FF54CDA8FF52CDA8FF5ACFACFF79D1B9FF32715AE7050D0A290000
            000300000000000000000000000000000000000000074F4ABAFF8C9DEEFF677D
            E8FF677CE8FF667BE8FF7C8FECFF443EB2FF0000000800000000000000000000
            0000000000000000000000000000000000000000000000000000000000021630
            4B677AAEDCFFD6F9FFFFA9F1FFFF8AEBFFFF89EBFFFFB3F3FFFF76A8D9FF142D
            4C6F0000000603070B1734669DD03675C1FF0000000700000000000000000000
            0000000000000000000000000000235A8DC03784C6FF3783C5FF3682C5FF3682
            C4FF3581C4FF3581C4FF3580C3FF9FE0F8FF7ED5F5FF8DCFF0FF3064A7E6040B
            1525000000020000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000101050A161C4D8CD081CCEDFF88E6
            FEFF81E4FDFF7FE4FDFF7EE0FAFF7CDFFAFF97E5FBFF1C61B5FF000000070000
            0000000000000000000000000000000000000000000000000000000000020611
            0D253C8B6FE493DDC8FF79DABFFF5AD1AEFF55CFAAFF55CEAAFF5CD0AEFF7CD3
            BBFF34775BE7050E0A2800000003000000000000000000000000000000000000
            000000000006514EBCFF8FA2F0FF6C81EAFF6C80EAFF6B80EAFF8194EEFF4742
            B5FF000000070000000000000000000000000000000000000000000000000000
            00000000000000000000000000010000000316314C667BB0DDFFD5F8FEFFAFF2
            FFFFB7F4FFFF77ABDBFF152F4E6D00000004000000010000000203070B172755
            8BBA000000040000000000000000000000000000000000000000000000000000
            00030000000400000004000000040000000400000004000000083783C6FFA8E5
            FAFF94D4F1FF3268A9E6050C1524000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010105
            0A141C5290CF96D3EEFFB7F4FFFFB6F3FFFFB6F2FFFFB5F2FEFFB4F1FEFFB2F1
            FEFFB1F0FEFF1E64B8FF00000006000000000000000000000000000000000000
            00000000000000000000000000000000000106110D243D8B71E495DDCAFF7BDC
            C0FF5CD1AEFF5FD1B0FF80D4BCFF337A5DE6050E0A2600000002000000000000
            000000000000000000000000000000000000000000055451BFFF94A6F1FF6F85
            EBFF6F85EBFF6E84EBFF8499EFFF4A45B7FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000317324C6678AFDBFDCDEBF8FF7BAFDCFF16314F6C000000030000
            0001000000000000000000000001000000020000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000043987C8FFA3DAF3FF336AAAE6050C1523000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000002276291B6378CCDFF378BCCFF378ACBFF3689
            CBFF3688CBFF3587CAFF3586CAFF3485C8FF3484C7FF3383C7FF000000040000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000106120E233E8E72E495DDCBFF83DFC5FF84D7BFFF347D61E6050F
            0B24000000020000000000000000000000000000000000000000000000000000
            0000000000045855C2FFA2B2F3FFA1B0F3FFA1B0F3FFA0B0F3FFA0B0F3FF4D49
            BAFF000000050000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000216314B613474
            B2DF1633506B0000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000043A8BC9FF3670
            ACE4050D16230000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0002000000030000000300000003000000040000000400000004000000040000
            0004000000040000000300000001000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000106120E223D8F
            75E38DD5C1FF368161E4050F0B23000000010000000000000000000000000000
            000000000000000000000000000000000000000000024E5195B96A6CCFFF696C
            CFFF696BCEFF696BCEFF686BCEFF4A4C93BA0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000020000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000002347AB1DF050D16220000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000106120E21287258BF05100B22000000010000
            00000000000000000000000000000000000000000000}
          ActionIndex = '5Arrows'
        end
        object dxRibbonGalleryItemIconSetsGroup1Item7: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000900000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000002000000050000
            0003000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0002000000060000000A00000007000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000030000000B000000110000
            00130000001300000013000000120000000C0000000300000000000000000000
            000000000000000000000000000000000000000000000000000100000006120C
            0B34724D43C80F09083400000006000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002000000090000000E0000000F0000000F00000010000000100000
            00100000001000000010000000100000000D0000000400000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000007966D60E3110B0A2D0000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000100000009311F1B718C6257E634201B770000
            000A000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000A6D4C43C39A6A5DFF9A6A5DFF996A5CFF99695BFF99695BFF6D49
            40C30000000B0000000000000000000000000000000000000000000000000000
            00000000000100000005120D0B34926D61E8D9C7C2FF7F5951E80F0A08350000
            0006000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000568483EB995665AFF9465
            59FF946558FF936457FF926356FF926255FF916154FF916154FF906053FF8F60
            53FF0000000D0000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000009AB7F70FF8860
            56E8110B0A2D0000000300000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000083221
            1C71AE8E85FFE9DEDAFFB09188FF36221D7A0000000900000002000000000000
            0001000000030000000600000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000FAE8474FFF4EEEBFFF0E8
            E4FFF0E8E4FFF0E7E4FFEFE7E3FFAC7F70FF0000001000000000000000000000
            00000000000000000000000000000000000100000005120D0B32956F65E7E6D9
            D4FFF0E6E3FFE2D5D1FF815D53EA0F0A08340000000600000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000020A07061D86655BD1E8DCD8FFFAF6F5FFF5EFECFFF3EDEAFFF3ED
            EAFFF3ECE9FFF3ECEAFFF2ECE9FF9D6E60FF0000000F00000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000008AD8173FFE6DBD7FF886258E7120B0A2C000000030000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000010000000834231E70B19189FFF2EBE7FFEFE8E4FFF1EAE6FFB294
            8CFF36231E790000000900000001000000030805041E715048BE000000090000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000EB08678FFF5EFECFFEFE6E2FFEFE5E2FFEEE5E1FFF0E8E5FFAE82
            73FF000000100000000000000000000000000000000000000000000000010000
            0005130E0C31967266E7E6DAD6FFF0E7E3FFF0E7E3FFF0E6E3FFE4D8D4FF825E
            54EA100A08330000000500000001000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000030A07061E8867
            5BD2E7DBD7FFF4EEEBFFF0E7E3FFF0E8E4FFF0E7E3FFEFE7E3FFF4EDEAFF9F71
            63FF0000000E0000000000000000000000000000000000000000000000000000
            000500000007000000080000000800000008000000080000000FAF8375FFF4ED
            EAFFE5D9D4FF89635AE7120C0A2C000000030000000100000000000000000000
            0000000000000000000000000000000000000000000540312C6DB4958CFFF2EB
            E8FFEFE8E4FFEFE7E4FFEFE7E3FFF2EBE8FFB4958DFF37241F780000000B0805
            041E6F4C43D4A07366FF0000000C000000000000000000000000000000000000
            0000000000000000000000000000000000000000000DB3897BFFF5F0EEFFF0E7
            E4FFEFE6E3FFF0E6E3FFF1E9E7FFB08577FF0000000F00000000000000000000
            0000000000000000000000000004130E0C2F98766AE6E9DDD8FFF1E8E6FFF0E8
            E5FFF1E8E4FFF0E8E4FFF0E7E4FFE5D9D5FF835F54EA100A0931000000050000
            0001000000000000000000000000000000000000000000000000000000000000
            000000000000000000010000000B432B2490BEA49CFFF2ECE8FFF0E8E5FFF0E8
            E5FFF0E8E4FFF0E8E4FFF4EDEBFFA17467FF0000000D00000000000000000000
            00000000000000000000000000006F4D42BCA47769FFA47768FFA37667FFA175
            66FFA17265FFA07264FFB08677FFF3EBE8FFF0E8E4FFE6D9D6FF8A645AE7120C
            0A2B000000030000000100000000000000000000000000000000000000000000
            0000000000079F796EECEEE4E2FFF1E9E6FFF1E9E5FFF1E9E6FFF0E9E5FFF0E8
            E5FFF3ECE8FFB6988FFF4A363183745147D4DCCEC9FFA37669FF0000000C0000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000CB58C7FFFF6F1EFFFF1E9E5FFF1E9E5FFF0E8E5FFF2EBE8FFB389
            7AFF0000000E0000000000000000000000000000000000000004140F0D2D9B7B
            6DE6EADFDAFFF2EAE8FFF2EBE8FFF1EAE7FFF1E9E7FFF1E9E6FFF0E9E6FFF1E8
            E5FFE7DAD6FF866157E9100A0931000000050000000100000000000000000000
            0000000000000000000000000000000000000000000100000008412A2484BDA1
            9BFFF3EDEAFFF1EAE6FFF1E9E6FFF1E9E6FFF1EAE6FFF0E8E6FFF5EFECFFA478
            6AFF0000000C000000000000000000000000000000000000000000000000B087
            77FFF7F2F0FFF5EFECFFF5EEEBFFF4EEECFFF4EEEBFFF4EDEBFFF4EDEAFFF4ED
            EAFFF1E9E6FFF1E9E6FFE7DBD7FF8C655BE7120C0A2B00000003000000010000
            000000000000000000000000000000000000000000044D3C3779CFB6AFFFF5EF
            EDFFF1EAE6FFF2EAE6FFF1EAE6FFF1E9E6FFF2EAE6FFF3EDEAFFCBB0A8FFDECF
            CAFFF5EFECFFA57A6DFF0000000B000000000000000000000000000000000000
            0000000000000000000000000000000000000000000BB99083FFF7F2F1FFF2EB
            E7FFF2EAE7FFF1EAE7FFF3ECEBFFB58C7EFF0000000D00000000000000000000
            000000000000140F0D2BA07E71E5EDE4E0FFF7F3F1FFF7F3F1FFF6F1EFFFF3EB
            E9FFF3ECE9FFF2EBE8FFF4EEEBFFF4EFEDFFF6F0EFFFEADFDCFF886358E9100B
            092F000000030000000000000000000000000000000000000000000000000000
            000100000007422D2783BFA59DFFF4EEEBFFF2EBE8FFF2EAE8FFF2EBE8FFF2EA
            E7FFF2EAE7FFF2EAE6FFF5EFECFFA67B6EFF0000000B00000000000000000000
            0000000000000000000000000000B48D7DFFF7F4F2FFF4EEEBFFF4EEEBFFF4ED
            EAFFF3EDEAFFF4EDEAFFF3ECE9FFF3ECE9FFF2EBE9FFF2EAE7FFF2EAE8FFE7DC
            D8FF8C665BE7120C0B2A00000002000000000000000000000000000000000000
            0000000000010000000654413C82D3BCB5FFF6F0EEFFF2EBE8FFF2EBE7FFF3EA
            E7FFF2EAE7FFF2EBE8FFF4EDEBFFF3ECE8FFF5EFEDFFA97E70FF0000000A0000
            0000000000000000000000000000000000000000000000000007000000090000
            000A00000011BB9487FFF8F4F2FFF4ECE9FFF3ECE9FFF3ECE9FFF4EEECFFB78F
            82FF000000150000000C0000000C0000000900000002AC8F86E0C6A599FFC5A4
            98FFC5A496FFBC9689FFF7F2F0FFF3EDEAFFF3ECEAFFF3ECEAFFF5F0EDFFB68D
            7FFFC09C90FFBF9B8EFFBF9A8DFFA7867AE40000000700000000000000000000
            000000000000000000000000000100000006452F2982C3A8A0FFF5EEEDFFF3EC
            E9FFF3ECE9FFF3ECE9FFF3ECE9FFF2ECE9FFF7F3EFFFF7F3F1FFF6F2EFFFAA80
            72FF0000000A000000000000000000000000000000000000000000000000B792
            84FFF8F4F3FFF5F0EDFFF5EFEDFFF5EFECFFF5EEECFFF5EEEBFFF4EDEBFFF4EE
            EBFFF4EDEBFFF3EDEAFFF3ECEAFFF3EDEAFFE6D8D3FF88685DC7000000040000
            0000000000000000000000000000000000000000000000000001000000065543
            3E81D4BEB7FFF6F0EFFFF3ECE9FFF3ECE9FFF3ECE9FFF3ECE9FFF3ECE9FFF3EC
            E9FFF5F1EFFFAB8175FF00000009000000000000000000000000000000000000
            0000000000009B7669E0B08679FFB08578FFAF8477FFBD988AFFF6F2EFFFF5EE
            ECFFF4EEECFFF4EDEBFFF6F0EEFFBA9385FFA97E6FFFA97D6FFFA87D6DFF946E
            61E40000000600000006000000080000000900000010BE9A8DFFF8F3F2FFF5EF
            EDFFF4EFECFFF4EEEBFFF6F0EEFFB89082FF000000130000000B0000000B0000
            0008000000020000000000000000000000000000000000000000000000034733
            2C80C6ADA6FFF5F0EEFFF4EDEBFFF4EDEBFFF4EDEBFFF3EDEBFFF4EDEAFFF8F4
            F2FFCDB5ADFFEBE0DDFFFBF8F7FFAC8377FF0000000900000000000000000000
            0000000000000000000000000000BB9688FFF9F6F5FFF7F1EFFFF6F0EFFFF6F1
            EEFFF5F0EEFFF6F0EEFFF6EFEDFFF5EFEDFFF5EFEDFFF4EEECFFF4EEEBFFEEE5
            E2FFA68479E6150F0E2600000001000000000000000000000000000000000000
            00000000000000000000000000010000000556443F80D6C0B9FFF6F2EFFFF4EE
            EBFFF4EDEBFFF4EEEAFFF4EDEAFFF4EDEAFFF7F1EFFFAF8579FF000000090000
            0000000000000000000000000000000000000000000017131127B4968BE5F4ED
            EAFFF9F6F5FFF8F4F2FFF7F3F1FFF6F0EDFFF6F0EDFFF5EFEDFFF6F2F0FFF6F2
            EFFFF7F1EFFFEFE6E4FFA57F74E8140F0D2A0000000300000000000000000000
            000000000008C19D90FFF9F5F3FFF6F1EFFFF6F0EEFFF6F0EEFFF7F2F0FFBB93
            86FF0000000A0000000000000000000000000000000000000000000000000000
            0000000000000000000000000004B08D81F1F8F5F4FFF8F4F3FFF5EFECFFF4EF
            ECFFF5EEECFFF5EEEBFFF8F5F3FFCDB4ADFF4C3A347B94746BD1EDE3E0FFB088
            7CFF00000009000000000000000000000000000000000000000000000000BF9B
            8FFFFBF8F7FFFBF8F7FFFBF7F7FFFAF8F7FFFAF7F7FFFAF7F7FFF9F7F6FFF8F5
            F4FFF6F0EEFFF6F0EEFFF0E8E4FFA8867CE615100E2600000002000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00010000000655403B89D0B9B2FFF5F0EEFFF4EEECFFF4EEECFFF5EFEBFFF5EE
            ECFFF7F2F1FFB1897DFF00000008000000000000000000000000000000000000
            0000000000000000000217131126B5998EE5F4EDECFFF9F5F4FFF7F2F0FFF7F1
            EFFFF6F1F0FFF6F0EFFFF6F1EFFFF6F0EEFFF1E8E5FFA88378E7150F0E290000
            00030000000000000000000000000000000000000007C3A094FFFAF6F5FFF7F3
            F0FFF7F2F0FFF7F1EFFFF8F4F3FFBD978AFF0000000800000000000000000000
            000000000000000000000000000000000000000000000000000000000002473A
            3667D4BEB6FFFCFAFAFFF8F4F3FFF5F0EDFFF5EFEDFFF9F6F3FFD0B8B0FF4738
            326F000000060B08081794786DD0B38C80FF0000000700000000000000000000
            00000000000000000000000000008E776FC0CDAFA4FFCCAEA4FFCBADA2FFCBAC
            A1FFCAABA0FFC9AA9FFFC8A99EFFF9F7F6FFF7F3F0FFF1E9E6FFAA8B7EE61511
            0F25000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010A080716907168D0E8DBD8FFF6F0
            EEFFF5F0EDFFF6F0EDFFF6EFEDFFF5F0EDFFF8F3F2FFB48E82FF000000070000
            0000000000000000000000000000000000000000000000000000000000021713
            1225B69C91E4F5EEECFFF9F6F5FFF8F3F1FFF8F3F1FFF8F2F0FFF8F2F1FFF1EA
            E8FFA9887BE715100E2800000003000000000000000000000000000000000000
            000000000006C6A497FFFAF7F6FFF8F3F2FFF8F3F2FFF7F3F2FFF9F4F4FFBF9A
            8DFF000000070000000000000000000000000000000000000000000000000000
            000000000000000000000000000100000003483B3666D6C0B8FFFBFAF9FFFAF5
            F4FFF9F7F6FFD3BBB4FF493A356D0000000400000001000000020B0808178368
            5FBA000000040000000000000000000000000000000000000000000000000000
            0003000000040000000400000004000000040000000400000008CBADA2FFFAF7
            F7FFF2EBE8FFAD8E84E616110F24000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010B08
            081491766DCFEBE1DDFFFAF8F5FFFAF8F5FFFAF8F5FFFAF8F5FFFAF7F5FFFAF7
            F5FFFAF8F5FFB89286FF00000006000000000000000000000000000000000000
            00000000000000000000000000000000000117141224B69C93E4F5EFECFFF9F6
            F6FFF9F5F3FFF8F4F2FFF3ECE8FFAD8C81E616110F2600000002000000000000
            00000000000000000000000000000000000000000005C7A79BFFFAF8F7FFF9F4
            F3FFF9F4F4FFF8F5F3FFF9F6F5FFC19D90FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000003493C3766D4BEB9FDF6F0EEFFD5BFB8FF4A3C376C000000030000
            0001000000000000000000000001000000020000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000004CEB2A7FFF4EDEAFFB09086E616121023000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000028F7971B6C9ABA0FFC9AA9FFFC8A99FFFC8A9
            9EFFC7A89DFFC7A79DFFC6A79CFFC5A59BFFC4A59AFFC4A499FF000000040000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000118141223B79D94E4F5F0EEFFFAF8F8FFF4ECEAFFB08F85E61611
            1024000000020000000000000000000000000000000000000000000000000000
            000000000004CAAA9DFFFBFAF9FFFBFAF9FFFBFAF9FFFBFAF9FFFBF9F8FFC3A0
            93FF000000050000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000002473B3761AA8C
            81DF4C3E396B0000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000004D1B5ABFFAF94
            8AE4161210230000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0002000000030000000300000003000000040000000400000004000000040000
            0004000000040000000300000001000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000118141322B99E
            96E3F0E7E2FFB09385E417121023000000010000000000000000000000000000
            0000000000000000000000000000000000000000000298837DB9D1B4A8FFD0B4
            A8FFD0B3A8FFCFB2A6FFCFB1A6FF957D75BA0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000020000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000002B9A197DF171211220000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000118141321977F76BF17121122000000010000
            00000000000000000000000000000000000000000000}
          ActionIndex = '5ArrowsGray'
        end
      end
      object dxRibbonGalleryItemIconSetsGroup2: TdxRibbonGalleryGroup
        Header.Caption = 'Indicators'
        Header.Visible = True
        object dxRibbonGalleryItemIconSetsGroup2Item1: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000030000000A0000000F000000090000000200000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000030000000A0000
            000F000000090000000200000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000030000000A0000000F00000009000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000B4F453CB86D5D51F1372E
            288B000000090000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000010000000B4F453CB86D5D51F1372E288B00000009000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000010000000B4F45
            3CB86D5D51F1372E288B00000009000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0003100E0C3489766BFFD4C0BBFF6D5C53EE0000000D00000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000003100E0C3489766BFFD4C0
            BBFF6D5C53EE0000000D00000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000003100E0C3489766BFFD4C0BBFF6D5C53EE0000000D0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000073F36318CAE9C94FFBCAAA1FF4E45
            3CB10000000A0000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000073F36318CAE9C94FFBCAAA1FF4E453CB10000000A000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000073F36318CAE9C
            94FFBCAAA1FF4E453CB10000000A000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000C72625BDCD4C3BAFF9F8E83FF25201D5B0000000400000000000000000000
            0002000000060000000B0000000D0000000D0000000900000000000000000000
            0000000000000000000000000000000000000000000C72625BDCD4C3BAFF9F8E
            83FF25201D5B00000004000000000000000000000002000000060000000B0000
            000D0000000D0000000900000000000000000000000000000000000000000000
            0000000000000000000C72625BDCD4C3BAFF9F8E83FF25201D5B000000040000
            00000000000000000002000000060000000B0000000D0000000D000000090000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000031715153C887E8BFFDDCDC7FF7F6E66EE0201
            011300000002000000030000000800010D2402084D89020B7DD1030E98F8030D
            9AFD01096DBA0000000000000000000000000000000000000000000000000000
            00031716153C8C878AFFDDCDC7FF7F6E66EE0201011300000002000000030000
            000803060D240F264A891A427DD12B5FA4F83169AEFD26507DBA000000000000
            000000000000000000000000000000000000000000031817143C8E8D7FFFDDCE
            C7FF7F6E66EE0201011300000002000000030000000803080624113023891D50
            39D127684EF8276A4EFD1B4A36BA000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000060715
            59944655BFFF7379BFFF111E68B80001081F0101081802052A50050C68AD0814
            A0FA0A16AAFF0B19B7FF0A1BC2FF0E29BEFF02074E8C00000000000000000000
            00000000000000000000000000000000000615325994528BC4FF7F9CC2FF203F
            69B80204081F0204081809172950163662AD1F529CFA1A61B3FF1677D0FF128C
            E6FF3396D4FF1B3A5B8C00000000000000000000000000000000000000000000
            0000000000061B4636945CA587FF86AF9AFF26523FB80205041F02050418091B
            1450164231AD236C4DFA29805CFF2B986EFF2EAA7DFF47A081FF1537298C0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000010000000A0D2597E55564DCFF2B45C1FF1929ACFF121F
            ACFF121EAEFF1421B5FF1422BAFF111EB0FF1222BAFF1223C3FF1D36D0FF0D1B
            A7FC01020F260000000000000000000000000000000000000000000000010000
            000A265697E53596DCFF3380CCFF3073B6FF2D6BAEFF2C67ABFF2970B7FF2075
            C7FF136AC4FF1577D2FF1587E1FF23A0EFFF377CBCFC060C1226000000000000
            0000000000000000000000000000000000010000000A2F785DE541B48CFF3A97
            77FF307F61FF2B785AFF2C785BFF2E8464FF2E936CFF298E65FF2E9D71FF2EA8
            7BFF41BC91FF327F63FC040B0826000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000002060C29483A4E
            BAFF566FE6FF354EC3FF4156DBFF5469E5FF3E55DFFF2639D1FF1828BCFF1423
            B4FF192AC3FF1B2ECDFF3147D0FF0A1172B20000000800000000000000000000
            00000000000000000000000000020C1929484F7FB8FF2D96E2FF3F85CEFF48B3
            EDFF59C0F8FF44B4F6FF2A98E7FF1B7BD1FF176CC6FF1A82DAFF1A8FE7FF3FA4
            E2FF28527EB20000000800000000000000000000000000000000000000000000
            00020E221B48569F84FF39B78EFF439A7BFF4ABF9AFF60CDAAFF4DC49FFF38B0
            86FF2D9B70FF2A9068FF30A478FF2FAD7FFF4FB593FF225442B2000000080000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000040C1B699F5867CFFF4D64DCFF435ACFFF5068E4FF657B
            ECFF3D53DFFF293DCFFF1A29B6FF1C2DBCFF2336CCFF2F45D9FF2938C3FF0508
            2C4C000000030000000000000000000000000000000000000000000000041D41
            689F5897CEFF4094DEFF4997DAFF55BDF4FF69C9F9FF3FADF2FF2A92E2FF1B70
            C6FF1C77CDFF208BE0FF2CA0EFFF4693D1FF1121314C00000003000000000000
            0000000000000000000000000000000000042359469F60B597FF46B38FFF48AA
            8AFF54C7A4FF69D3B3FF44C095FF35AD81FF2A8F67FF2F9A6FFF31A97DFF3BB8
            8DFF48A080FF0E221B4C00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000101020A1732AAEF6275
            E7FF546CDAFF5068DFFF677EEDFF657CEDFF3C52DEFF283DCBFF1C2BB4FF2639
            C9FF2C42D6FF4B61E0FF19239DD9000000080000000100000000000000000000
            000000000000000000000101020A346CA8EF3DA2E4FF5096E0FF56B0EAFF6CCA
            F8FF68C8F9FF3EA8EDFF288ADAFF1C6CC2FF2484D7FF2896E7FF49AFEEFF3C74
            AAD9000000080000000100000000000000000000000000000000000000000102
            020A3A9072EF4AC5A0FF54B093FF4DBC9AFF63D0B1FF62D1B0FF3FB990FF32A5
            7AFF298A64FF32A479FF32AF82FF51BF9CFF357E63D900000008000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000081036534C5DC4FF667AECFF627AE0FF5D75EAFF7E94F4FF5973
            ECFF3951DBFF2436BFFF2233BBFF2E44D2FF3952E0FF485AD7FF101553750000
            0003000000000000000000000000000000000000000000000000112436535E91
            C3FF45A4E9FF5E9DE4FF64C4F5FF83D5FBFF5CBFF6FF3BA2E8FF257BCCFF2375
            C8FF2C8FDEFF33A2EDFF58AAE2FF203E59750000000300000000000000000000
            0000000000000000000000000000132F265364B095FF4EC9A6FF5AB498FF55C9
            A6FF77DBBFFF53C9A5FF3AB48AFF2D956DFF2D936BFF34AA80FF37B58AFF57B7
            98FF1D4335750000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000013247AAA6D7AD8FF657B
            EAFF647DE6FF6E86F0FF869DF5FF4C67E8FF455BD9FF3142B8FF4A5BCDFF677D
            E1FF728AEDFF2C3AC3F502030914000000010000000000000000000000000000
            0000000000000000000029537AAA68A8D6FF5BA6EBFF67AEEBFF75D0F9FF8CDA
            FDFF52B8F3FF47A1E2FF3579C1FF4D96D5FF67B6E8FF6EC8F4FF4E92D0F50407
            0A14000000010000000000000000000000000000000000000000000000002B6B
            56AA6EC6AAFF5CC7A9FF59BFA0FF62D2B1FF7CDCC2FF46C29AFF46B590FF3A91
            70FF51AF8EFF66C6A9FF69D2B3FF48A282F50308061400000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000001E36AFEE8695F0FF7890EEFF6681EDFF8EA4F6FF8FA5F6FF748B
            E9FF4657CCFF2936BBFF2A37C0FF2934C6FF3847D3FF1C237A9B000000030000
            00000000000000000000000000000000000000000000000000003F79B1EE5DB4
            ECFF6EA5EEFF71C6F4FF97DEFBFF95DDFCFF7DC7EFFF5398D4FF377AC2FF3A7F
            C7FF4188D0FF539EDFFF2F5B839B000000030000000000000000000000000000
            00000000000000000000000000003F9E7FEE63D7B8FF6CC5AAFF5ACBAAFF81DF
            C6FF84DFC6FF6FCFB4FF4FA988FF368966FF398D69FF3F9974FF50B18DFF2F67
            519B000000030000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000F1A5474233DBEFD475F
            CFFFA3B8F6FFAFBFF6FF7082E9FF3A48D1FF1B258AB70B0E3A54050719260000
            00050607192204050F1600000001000000000000000000000000000000000000
            000000000000000000001F3C5574468AC2FD65A5D4FFB0E6FBFFBCE6FBFF83C6
            F0FF5299DCFF2A5A90B70F253B5408111A26000000050A121B22060B10160000
            0001000000000000000000000000000000000000000000000000000000001E4C
            3E7445AD8CFD5CBCA0FF98E6D2FFACE9DAFF76D0B4FF4DAA87FF27644BB70E28
            1C5407130E260000000509151122060D0A160000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000002151A4654434FC0DC5865E2FF414BB9D32329758D0507
            1822000000020000000100000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000021F35
            49545C97C6DC75B6EBFF5992C1D332587B8D0811192200000002000000010000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000021E3D325456A88DDC6BC8A7FF54A1
            87D32E64518D08130F2200000002000000010000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3Flags'
        end
        object dxRibbonGalleryItemIconSetsGroup2Item2: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            000000000001000000070000000D0000001100000012000000110000000D0000
            0007000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000070000
            000D0000001100000012000000110000000D0000000700000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000002000000070000000C00000010000000120000
            00110000000E0000000800000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000D100C3369231A6EC22B22
            8EEF30249BFF2A218EEF21186DC20F0C326A0000000E00000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000040000000D0B1C3669183B73C21C4C94EF2152A2FF1C4B94EF1738
            71C20A1B356A0000000E00000004000000010000000000000000000000000000
            0000000000000000000000000000000000000000000100000004000101120F29
            1D791A4B36C624674AFF24674AFF24684AFF1B503AD2112D2184000101150000
            0005000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000050404
            0D27231D6CBC3732AAFF3944C7FF3A4CD5FF3B4EDBFF394AD5FF3740C6FF332E
            A8FF211A6BBD04030D2900000005000000010000000000000000000000000000
            00000000000000000000000000010000000503070E27183C72BC2D69B3FF4393
            D3FF4EA7E3FF51AEE9FF4CA5E2FF4090D2FF2A65B1FF153870BD03070E290000
            0005000000010000000000000000000000000000000000000000000000000000
            000000000005050E0A351D563FDC287B5AFF2FA57BFF33BD8FFF34C090FF34BE
            90FF30A77DFF29805EFF1B523CD406100B3D0000000700000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000408071735352D95EB4349C3FF586DE2FF5D71E4FF4A5F
            DFFF3F53DCFF3E52DCFF4A5EDEFF5C6EE1FF5157CAFF392F97EE05040F2B0000
            000400000000000000000000000000000000000000000000000000000004050E
            183525589CEB408BCCFF57B3EAFF56B3EBFF67BBEDFF82CAF1FF82CAF2FF63BA
            ECFF50AEE8FF3A85C9FF205198EC0308102B0000000400000000000000000000
            000000000000000000000000000000000003050D0A31216247ED2E9772FF36C0
            93FF35C193FF5CCEA9FF6DD4B2FF42C69AFF37C193FF39C296FF319E77FF266C
            4FF806100C3D0000000500000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000001010210332D89D7454E
            C9FF525DD6FF4237B8FF5353CBFF6477E5FF4F63E0FF4F63DFFF4B49C5FF3F33
            B6FF5A63D7FF4E57CDFF25206FBB0000000D0000000100000000000000000000
            000000000000000000000101021023538ED74997D4FF5DB8EDFF5CB7ECFF5BB6
            ECFF4084CDFF104BADFF4D8BCEFF75C3F0FF55B2EAFF54B1EAFF418FD0FF193E
            72BB0000000D0000000100000000000000000000000000000000000000000000
            000A1D533CD0349F7AFF3AC295FF35C092FF52CBA5FF257E5BFF05623AFF4BB8
            94FF38C395FF38C395FF3BC498FF37A781FF1F5941D300010113000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000019163F6C4C4BBAFF4D62E1FF3F34B7FFE8E6F6FFA69FDCFF5352
            C9FF6C80E7FF4F4CC6FFB1ABE0FFEAE9F7FF4136B8FF4E63E0FF4341B4FF1511
            38690000000500000000000000000000000000000000000000001027416C3E81
            C1FF63BDEEFF62BBEDFF60BAEDFF5FB9EDFF1451B0FFB9CAE7FF1651B0FF6BBF
            EEFF59B5EBFF59B4EBFF57B4EAFF3878BCFF0E213A6900000005000000000000
            00000000000000000000000000000C22185E328564FF42C69BFF37C294FF51CC
            A6FF38906FFF89AD9DFFB2CDC0FF28855FFF4CCCA5FF3DC79BFF3AC597FF45C9
            A0FF368F6EFF1030237F00000007000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000034317DBD545FD3FF5267
            E1FF4546C7FFA498CFFFF0E6E4FFA498CEFF473DBBFFAEA3D1FFEEE5E2FF9F92
            CDFF4848C7FF495CDFFF4A53CEFF2D2876BF0000000A00000000000000000000
            00000000000000000000215281BD58A6DCFF67C0EFFF66BEEFFF65BEEEFF63BC
            EFFF3882CCFF104BADFF3781CCFF5FB9EDFF5DB8ECFF5CB8ECFF5CB7ECFF4E9C
            D7FF1E497CBF0000000A00000000000000000000000000000000000000001A4A
            36B643AD8AFF40C69CFF51CEA6FF479E80FF6B9582FFF7F1EEFFF8F3EEFF387B
            5CFF5BBE9EFF4ACEA5FF45CBA1FF43C9A0FF47B692FF1E5842CD0000000B0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000004844A7ED5769DEFF576BE4FF556BE3FF4544C4FFADA2D2FFF1E8
            E5FFD3C9DDFFEFE6E4FFA59ACFFF4B4BC8FF4E63E1FF4D62E1FF4C5EDBFF3F38
            9EEB0000000B00000000000000000000000000000000000000002E70AAED68BD
            EAFF6CC4F1FF6BC2F0FF6AC2F0FF68C0EFFF6BC1F0FF84CEF3FF83CDF3FF67BF
            EFFF62BCEEFF61BBEDFF60BAEDFF5BB2E7FF2963A2EB0000000B000000000000
            00000000000000000000000000001F5F44DF51C4A1FF4BCBA5FF54AE90FF507F
            69FFEFE9E6FFBFC2B5FFEEE3DEFFCEDCD4FF1F704EFF66D6B5FF4FD1A9FF4ECF
            A7FF57CDA9FF287557F80000000E000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000005451BCFF6176E5FF5B70
            E5FF5A70E5FF6478E6FF483EBBFFD8CEE0FFF1E8E5FFD2C8DCFF473EBCFF7385
            EAFF5F73E5FF5267E1FF586BE2FF4945AFFA0000000B00000000000000000000
            00000000000000000000367FBFFF76C8F2FF70C6F1FF70C6F1FF6EC5F1FF6DC4
            F0FF6FBAEAFF1D58B4FF84C4ECFF79C9F2FF67BFEFFF65BFEFFF64BDEEFF68BE
            EEFF2E72B2FA0000000B0000000000000000000000000000000000000000246B
            4FF26BD3B5FF4DCCA5FF0F6240FFD1D1CBFF6C8D78FF156642FF74947EFFF0E8
            E3FF749F8AFF4AA183FF64D8B6FF53D2ACFF71DCBFFF2B7F5EFF020604190000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000005151B0EC7384E6FF5F75E6FF697EE7FF5452C8FFADA3D4FFF2EA
            E8FFD5CBDEFFF1E9E7FFA69CD1FF5755C9FF7588EAFF6175E5FF687AE3FF4844
            A6EA0000000A00000000000000000000000000000000000000003579B2EC81CC
            F1FF75CBF3FF74C9F3FF73C9F2FF71C8F2FF4384CBFF9AB3DCFF4D88CCFF86D0
            F4FF6BC3F1FF6BC2F0FF69C1F0FF75C2ECFF2E6DAAEA0000000A000000000000
            0000000000000000000000000000226548DC7CD4BBFF58D3AEFF43B48FFF0D64
            40FF349674FF5DD7B4FF329371FF74947EFFEFEAE7FF52856CFF5EB698FF61D7
            B5FF84DDC4FF2B7D5CF80000000C000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000042428BBA7F8AE0FF6479
            E8FF5352C9FFA59CD3FFF3ECEAFFA59BD2FF453CBBFFB0A5D4FFF2E9E7FFA096
            CFFF5A5ACCFF6B80E9FF7782DDFF3C3A85BC0000000700000000000000000000
            000000000000000000002A628DBA80C2E7FF7ACEF4FF79CDF4FF78CCF4FF77CB
            F4FF225FB7FFDDE6F3FF2560B8FF8DD4F5FF70C7F1FF6FC6F2FF6EC5F1FF75BA
            E3FF265A88BC0000000700000000000000000000000000000000000000001B4E
            3AAB7BC4AEFF68DAB9FF5CD6B3FF5FD8B6FF62DAB9FF64DBBAFF65DDBDFF2D87
            66FF6B8C77FFE5E0DCFF1B6746FF65D2B1FF87D1BBFF21634BC6000000090000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000232347627075D3FF8094EEFF4136B8FFDFD7E6FFA095D1FF5252
            CAFF6378E7FF4C4AC5FFAAA0D3FFDFD7E3FF4237B8FF7E91EDFF6A6DCDFF1F1E
            4262000000030000000000000000000000000000000000000000163347625AA4
            D5FF94DAF8FF7DD1F5FF7DCFF5FF7BCFF5FF1450B0FFF7F9FCFF1550B0FF84D1
            F5FF75CAF2FF74C9F3FF8AD3F5FF549CD0FF142E426200000003000000000000
            00000000000000000000000000000B1F1747479779FF99E8D4FF60D8B6FF64DB
            BAFF67DDBBFF6ADFBDFF6DE0C2FF6DE1C3FF3E9C7CFF23694AFF2D8663FF9CEB
            D7FF51A78AFF1234276D00000004000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000010102095152A2D08893
            E3FF7580E0FF4137B8FF5154CDFF687DE9FF677CEAFF667BE9FF4C4CC8FF3F33
            B6FF6F78DDFF838DE0FF414185B5000000070000000100000000000000000000
            00000000000000000000010202093376A2D084C5E7FF9DDFF9FF82D3F6FF7FD3
            F6FF458CD0FF104BADFF448BD0FF7ACFF5FF7ACEF4FF94D9F7FF7EBFE4FF2860
            88B5000000070000000100000000000000000000000000000000000000000000
            00041F5C45B57CC2ABFF9EEAD7FF6BDEBCFF6AE0BFFF6FE1C3FF71E2C5FF72E3
            C6FF71E4C6FF64D0B3FF9BE9D5FF8ACFB9FF287257D20102010C000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000010F0F1D2A5F62BBEA858FE0FF9BABF1FF7E93EDFF7187
            EBFF6A80EAFF7084EBFF7C90EDFF98A8F1FF828BDEFF5A5BB8E9090913200000
            0002000000000000000000000000000000000000000000000000000000010916
            1D2A3D8CBCEA7BC0E4FFADE4F9FF95DDF8FF89D7F7FF82D4F6FF87D5F6FF90D9
            F7FFA8E1F8FF77BBE2FF3A84B9E9060E13200000000200000000000000000000
            00000000000000000000000000000000000103090718277759DA74BDA6FFB8EF
            E1FF9CEBD7FF8AE8D1FF7BE5CAFF8DEAD3FFA0EEDBFFBDF1E5FF7CC9B1FF2F8B
            6AEA0715102E0000000200000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010909
            111B494B8EB2767AD7FF939FE9FFA1AFF1FFA7B7F4FFA0AFF1FF929DE8FF7377
            D5FF45488CB30809111C00000002000000000000000000000000000000000000
            000000000000000000000000000000000001060D111B2D698EB258A9D9FF93D0
            EEFFADE2F6FFBAEAFBFFACE1F6FF90CEEDFF57A6D7FF2D668CB3050C111C0000
            0002000000000000000000000000000000000000000000000000000000000000
            000000000001030A071720664CB849A685FF89CEB9FFABE3D4FFC7F1E9FFAEE6
            D6FF8DD4BFFF50B190FF267B5CCB06120E270000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000320213E5040427B9B5556
            A6CC686BCCF95456A5CC3F407B9B1F203D510000000400000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000100000003142E3E50285C7B9B367CA6CC4198CCF9367CA6CC285C
            7B9B142D3D510000000400000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000030B23
            1B411E5C469D297F61CF319675EE298365CF236C54B010312556000000060000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3Symbols'
        end
        object dxRibbonGalleryItemIconSetsGroup2Item3: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000020000000A00000010000000090000
            00020000000000000000000000020000000C000000160000000E000000030000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000001000000050000000B0000000B0000
            0005000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000020000
            000E0E0E4987191991E8080838760000000F0000000200000002000000110303
            337E06067DEB02023E9400000017000000030000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000506163059124597EB124497EB05152F590000000500000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000030000000E000000150000
            000C000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000811114E873332BDFF4242CDFF2B2BB1FE0909
            3A7B0000001100000012060637801E1DA4FE3031C0FF1B1CA7FF03023F960000
            000F000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000A174C9AE871B7E7FF58ACE7FF1347
            96E80000000B0000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000200000012072B189C136940FF051E127A0000000C00000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000000000000B2727
            A7F36565DDFF4C4CD7FF4A4AD5FF2C2CB3FE09093B8008083A822424AAFE3C3C
            CAFF3A3BC8FF4F4FCEFF090787F5000000160000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00092463A3EA7DC4EBFF7AC0EAFF184F9CEB0000000A00000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000200000010082D1B9A278B63FF3CB58BFF1562
            3EF4020B063D0000000600000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000610103E6B4746C1FE6C6DE2FF5050DAFF4D4E
            D8FF2E2EB4FE2A29B1FE4444D0FF4142CFFF595AD6FF2B2AAAFE0303327C0000
            000C000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000040B1F2F4D215E93D01B518FD00818
            2C4D000000040000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000020000000E082F
            1C972C9068FF45C097FF44BF96FF36A67DFF0B452BCE00000015000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            00091010406E494AC2FE7071E4FF5354DDFF5051DBFF4D4DD8FF494AD5FF6161
            DAFF3232B0FE0606367D00000011000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000050000000C0000000D000000050000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000010000000C09321F9430966FFF56CAA4FF95E3C8FF7BD7B8FF48C3
            9AFF2A8D65FF082B1A8A0000000C000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000A111140724545C2FE5859
            E1FF5556DEFF5152DBFF4D4ED8FF3333B4FE0706387F00000011000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000060B2A5F96092A5F960000
            0006000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000060A352190349B75FF7BDB
            BBFFACE9D3FF4EA07EFF6DB99AFF7DDABBFF4CC49DFF1F7851FC03120B480000
            0007000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000091212416F4648C6FE6E72EBFF7075EAFF6C71E8FF6366E3FF3334
            B7FE0808397D0000001100000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000101050A191D56AAF71B54AAF701050A190000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000084B8E60FF99E8CEFF90D0B7FF277F5BEF09281B680E422D9A6EBA
            9DFF75D9B7FF4ABE97FF186647E70209062B0000000400000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000061414446A5456CDFE8B90F2FF898F
            F3FF9BA1F3FF989DF2FF7E85EDFF7980EBFF3C3EBAFE080839780000000F0000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000030B2140684E8BCCFF3E83CBFF091E
            3D65000000030000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000003082016494D9063FF1457
            3BB2020B0723000000070000000C135239B280CAAEFF71D8B8FF46B691FF1256
            38CA000101140000000200000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000031515
            43635D5FD2FD9EA5F8FF9DA5F9FFAEB3F7FF5F60CAFE5C5EC8FEA5ABF4FF8D95
            F1FF8990EFFF4144BBFE08083774000000090000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0005173E6EA475B3E1FF58A7E1FF143B6BA40000000500000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000300000006000000050000000200000000000000020103
            02121A6344C28CD3B9FF7ADDBEFF3FAA84FF0D432CA10000000D000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000053D3CBAF1B6BBF9FFB1B9FBFFBCC2FBFF686A
            D0FE1212416F101040725E60C8FEAFB6F6FFA0A7F4FFA2A8F0FF1C1B99F40000
            0010000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000006275E97D394D2F2FF6BC2F2FF2259
            95D6000000060000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002010503151B6747C484CFB3FF81E1
            C4FF38A27BFF0B34237D00000007000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000031D1D
            56757E81DFFFBEC3F7FF6E6FD5FD1414446A000000090000000A1110406E6163
            C9FEB2B6F1FF6669CCFF0D0D47840000000A0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0006357AB5F1A9E4FBFF80D5FBFF3072B2F10000000600000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000101030210165E42B27ECCAFFF97E9D0FF4E9265FF000000090000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000041D1D56753838AFE4161646660000
            00060000000100000001000000091110416D26259BE6111149810000000D0000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000053A81B5E99BD7F3FF9BD6F3FF387A
            B1E9000000050000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000010002010B1557
            3DA5509769FF0822184A00000004000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000030000000500000003000000010000000000000000000000010000
            00060000000B0000000700000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0002112533453575A1CC3472A0CC102432460000000200000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000600000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000100000003000000030000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3Symbols2'
        end
      end
      object dxRibbonGalleryItemIconSetsGroup3: TdxRibbonGalleryGroup
        Header.Caption = 'Shapes'
        Header.Visible = True
        object dxRibbonGalleryItemIconSetsGroup3Item1: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            0000000000000000000000000002000000090000000E00000009000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000070000000D00000011000000120000
            00110000000D0000000700000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000000000020000000D0A06
            389230249BFF090636930000000D000000020000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000090000
            000D0000000E0000000E0000000F0000000F0000001000000010000000110000
            0011000000110000001200000012000000110000000C00000003000000000000
            00000000000000000000000000000000000000000001000000040000000D0E24
            1B691E4D38C2256349EF296D51FF256348EF1D4D38C20D241A6A0000000E0000
            0004000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000020000000C0B093A922A30A7FF3E50DBFF282FA4FF090636930000
            000D000000020000000000000000000000000000000000000000000000000000
            000000000000000000001D4682CC255BA8FF245AA7FF2459A6FF2357A6FF2257
            A5FF2256A4FF2254A4FF2154A3FF2153A3FF2053A2FF2051A1FF2051A1FF1F50
            A1FF183F7BCF0000000B00000000000000000000000000000000000000000000
            000100000005040907271D4D3ABC328063FF46AC8BFF4EC19DFF51CAA5FF4DC1
            9CFF43AB89FF317F61FF1D4938BD040907290000000500000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000B0E0B3E912D35ABFF4055
            DCFF4053DCFF4055DCFF2A31A6FF090637920000000C00000002000000000000
            00000000000000000000000000000000000000000000000000001B437ABD71B1
            DFFF5CB7EBFF5BB6EBFF5AB5EBFF59B4ECFF59B4EBFF58B3EAFF57B3EAFF57B2
            EAFF56B2EAFF56B1EAFF56B2EAFF68A5D6FF102D65C10000000B000000000000
            00000000000000000000000000000000000406100C35296A51EB42A181FF51C9
            A4FF4DC8A2FF4AC7A0FF47C59FFF49C6A0FF4CC7A1FF4FC8A2FF3F9F7EFF2967
            4EEC040A082B0000000400000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            000A100D42903138AFFF4458DEFF4458DEFF4457DEFF4357DDFF4358DDFF2C33
            A8FF0A0739910000000C00000002000000000000000000000000000000000000
            00000000000000000000060F19323974B4FB7AC7EFFF5FB8ECFF5EB8EDFF5EB8
            EDFF5CB7ECFF5CB6ECFF5BB6ECFF5BB6ECFF5AB5ECFF59B5ECFF73C1EEFF2A59
            9DFB040A15390000000400000000000000000000000000000000000000000101
            0110245F49D747AA8AFF53CBA7FF4DC8A3FF4BC8A1FF4AC7A1FF4AC7A1FF49C6
            A0FF49C69FFF4AC7A1FF50C9A3FF43A686FF1D4C3ABB0000000D000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000001000000091210468E363EB3FF495EE0FF495CDFFF495C
            DFFF485DDEFF485DDFFF465BDFFF475CDEFF2E36AAFF0A0739910000000B0000
            0002000000000000000000000000000000000000000000000000000000061838
            5F9368A6D7FF6AC0EFFF63BCEEFF62BBEDFF62BAEDFF60BAEEFF60BAEDFF5FB9
            EDFF5FB8ECFF63BBEEFF5D95C9FF0E2750980000000A00000001000000000000
            0000000000000000000000000000122C216C3F8E72FF57CDAAFF4FCAA4FF4DC9
            A4FF4DC9A4FF4DC9A3FF4CC8A3FF4CC8A3FF4BC8A2FF4AC7A1FF4BC8A2FF51CA
            A6FF3C8B6EFF0F271E6900000005000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000814134A8D3B44
            B8FF4E63E1FF4D62E1FF4D62E0FF4C61E0FF4C61E0FF4C61E0FF4C60E0FF4C60
            E0FF4B5FE0FF3039ADFF0B083C900000000A0000000100000000000000000000
            000000000000000000000000000102050916306CA6E985CAEEFF68BFEFFF67BF
            EFFF66BEEEFF66BEEEFF65BDEEFF63BCEEFF63BCEEFF7EC3EAFF204D91EA0104
            071C000000020000000000000000000000000000000000000000000000002457
            43BD52B495FF56CDA9FF50CBA7FF51CBA6FF50CBA5FF4FCAA5FF4FC9A5FF4EC9
            A5FF4EC9A4FF4DC8A3FF4CC8A3FF50CAA4FF4DB091FF215240BF0000000A0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000019174E8B4149BDFF5267E1FF5267E3FF5266E3FF5166E2FF5166
            E2FF5166E3FF5065E2FF5065E2FF5065E1FF4F64E1FF4F64E1FF333CAFFF0B09
            3E8E000000060000000000000000000000000000000000000000000000000000
            0004122B42665B9DD0FF7BCBF3FF6CC3F0FF6BC2F0FF6AC1F0FF69C1F0FF68C1
            EFFF76C7F1FF4F87BFFF0B1F386B000000060000000100000000000000000000
            00000000000000000000000000002E7359ED5CC9A9FF55CEAAFF53CDA9FF52CD
            A8FF52CCA8FF52CCA7FF51CBA7FF50CAA6FF4FCBA6FF4FCAA6FF4FCAA5FF50CB
            A5FF56C6A5FF2B6E55EB0000000B000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000005451BCFF7689EBFF576C
            E4FF566CE3FF566BE4FF566BE3FF556AE3FF556AE3FF546AE3FF5469E3FF5369
            E4FF5469E2FF5467E2FF7286EAFF4A45B3FF0000000900000000000000000000
            00000000000000000000000000000000000100000008275F90C986C6E9FF71C7
            F1FF70C6F1FF70C5F1FF6EC5F1FF6EC4F0FF7FBDE3FF1A487FCB0000000C0000
            0001000000000000000000000000000000000000000000000000000000003681
            65FF68D3B5FF56CEABFF56CEABFF55CDABFF55CDABFF54CDAAFF53CDAAFF53CC
            A8FF52CCA8FF51CCA8FF51CBA7FF51CAA7FF61CFB0FF307A5CFA0000000B0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000222258876F76D1FF7A8DECFF5A70E5FF5A6FE5FF5A6FE5FF596F
            E5FF596EE5FF596EE4FF596DE5FF586DE4FF586CE4FF778AEAFF646BC8FF1918
            4D8A000000050000000000000000000000000000000000000000000000000000
            0000000000020A19243B4C94C9FD88D2F4FF75C9F3FF74C9F3FF73C9F2FF87D1
            F4FF407EBBFF0814224200000004000000000000000000000000000000000000
            000000000000000000000000000034775EEC73D2B7FF59D0AEFF58CFADFF57CF
            ADFF57CFADFF57CFABFF55CEACFF56CEABFF55CEABFF54CDAAFF53CDA9FF54CE
            A9FF6DCFB2FF2F735AEA0000000A000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000625235987727A
            D3FF7E90ECFF5F74E6FF5F74E6FF5D73E7FF5E73E6FF5E73E6FF5C72E6FF5D72
            E5FF7B8EECFF6870CCFF1C1B5189000000080000000100000000000000000000
            000000000000000000000000000000000000000000000000000626587FAC82C2
            E6FF7CCEF3FF79CDF3FF7ACDF3FF7CB8DFFF194573AF00000008000000000000
            000000000000000000000000000000000000000000000000000000000000275F
            4ABA73C3ACFF60D2B2FF5AD0AFFF59D0AEFF59D0AEFF59D0AEFF58D0AEFF57CF
            ACFF57CFADFF56CEABFF56CEABFF5ACFADFF6FC0A8FF265B48BC000000070000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000010000000526265C86767ED6FF8094EEFF6278E8FF6278
            E7FF6278E7FF6177E8FF6177E7FF7F92EDFF6C74CFFF1E1E5488000000070000
            0001000000000000000000000000000000000000000000000000000000000000
            00000000000000000002060F15244690C3F596D8F6FF7CD0F4FF94D6F4FF397B
            B5F6050C13280000000200000000000000000000000000000000000000000000
            000000000000000000000000000015302662539F86FF7DDDC4FF5DD3B2FF5BD2
            B0FF5BD2B0FF5BD1B0FF5AD1B0FF5AD0AFFF59D0AEFF59D0AEFF59D1ADFF79DA
            C0FF509C82FF132D236200000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010000
            000528295E857880D9FF8496EFFF657CE9FF657BE9FF657BE9FF8295EFFF7179
            D2FF212157870000000600000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000041E45
            608076BAE1FF86D5F7FF6DAED9FF163A58830000000500000000000000000000
            0000000000000000000000000000000000000000000000000000000000000102
            01092E6F59D077C2ACFF84DFC7FF60D3B4FF5DD2B2FF5DD3B2FF5DD2B1FF5CD2
            B1FF5CD1B0FF5DD2B1FF81DEC4FF74BFAAFF265C48B500000007000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000100000004292A5F857A83DAFF8699
            EFFF687EE9FF8599EFFF737CD5FF23235A860000000500000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000010204050D3B83B2DFA5DDF4FF2D71A6DF0103
            040F000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010914102A3B8169EA6FBAA3FF97E4
            D0FF78DCC1FF66D7B7FF5FD4B3FF65D6B6FF77DBBFFF94E3CFFF6DB8A2FF377C
            65E9060D0A200000000200000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000042A2B61847D86DCFFA4B5F4FF7680D7FF24255C850000
            0004000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0002142E3E534399D0FF0F273953000000030000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000001050C091B2A604DB2509E84FF84CCB7FF9AE1CFFFA5EBDAFF9AE1
            CFFF82CCB7FF4F9D83FF295F4CB3050C091C0000000200000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000032C2D
            62836C6FD2FF26275D8300000004000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000200000004000000030000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000100000003122A
            22502454439B31705ACC3D8B6EF931705ACC2454439B122A2251000000040000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3Signs'
        end
        object dxRibbonGalleryItemIconSetsGroup3Item2: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            000000000001000000070000000D0000001100000012000000110000000D0000
            0007000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000070000
            000D0000001100000012000000110000000D0000000700000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000070000000D00000011000000120000
            00110000000D0000000700000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000040000000D100C3369231A6EC22B22
            8EEF30249BFF2A218EEF21186DC20F0C326A0000000E00000004000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000040000000D0B1C3669183B73C21C4C94EF2152A2FF1C4B94EF1738
            71C20A1B356A0000000E00000004000000010000000000000000000000000000
            00000000000000000000000000000000000000000001000000040000000D0E24
            1B691E4D38C2256349EF296D51FF256348EF1D4D38C20D241A6A0000000E0000
            0004000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000050404
            0D27231D6CBC3934ABFF414CC9FF4557D8FF475ADEFF4454D8FF3F48C8FF3530
            A9FF211A6BBD04030D2900000005000000010000000000000000000000000000
            00000000000000000000000000010000000503070E27183C72BC2F6AB3FF4B98
            D4FF58ADE4FF5DB5EBFF57ABE3FF4895D4FF2D67B1FF153870BD03070E290000
            0005000000010000000000000000000000000000000000000000000000000000
            000100000005040907271D4D3ABC328063FF46AC8BFF4EC19DFF51CAA5FF4DC1
            9CFF43AB89FF317F61FF1D4938BD040907290000000500000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000408071735352D95EB444AC3FF4A5EDEFF455ADEFF4156
            DDFF3F53DCFF4054DDFF4257DCFF4657DCFF3E44C0FF302891EC05040F2B0000
            000400000000000000000000000000000000000000000000000000000004050E
            183525589CEB468ECDFF60B8EBFF5BB6ECFF58B3EAFF54B1EAFF55B1EAFF57B3
            EAFF59B3EAFF4189CAFF205198EC0308102B0000000400000000000000000000
            00000000000000000000000000000000000406100C35296A51EB42A181FF51C9
            A4FF4DC8A2FF4AC7A0FF47C59FFF49C6A0FF4CC7A1FF4FC8A2FF3F9F7EFF2967
            4EEC040A082B0000000400000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000001010210332D89D74C55
            CAFF5064E1FF485DDFFF4559DEFF4459DDFF4358DDFF4257DDFF4156DCFF4257
            DDFF485BDEFF434CC7FF25206FBB0000000D0000000100000000000000000000
            000000000000000000000101021023538ED74F9BD5FF64BCEEFF5EB8ECFF5BB6
            ECFF59B5EBFF58B4EBFF57B4EBFF57B2EBFF57B3EAFF5CB5EBFF4894D1FF193E
            72BB0000000D0000000100000000000000000000000000000000000000000101
            0110245F49D747AA8AFF53CBA7FF4DC8A3FF4BC8A1FF4AC7A1FF4AC7A1FF49C6
            A0FF49C69FFF4AC7A1FF50C9A3FF43A686FF1D4C3ABB0000000D000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000019163F6C4E4DBBFF566BE3FF4E64E0FF4C61E0FF4A5FDFFF4A5E
            DFFF485EDFFF485DDFFF475CDEFF445ADEFF465BDEFF4C61DFFF4544B5FF1511
            38690000000500000000000000000000000000000000000000001027416C4082
            C1FF6CC1EFFF64BCEDFF60BAEDFF5FB9EDFF5EB8ECFF5DB7ECFF5CB6ECFF5BB6
            ECFF59B5EBFF5BB5EBFF60B9EBFF3B79BCFF0E213A6900000005000000000000
            0000000000000000000000000000122C216C3F8E72FF57CDAAFF4FCAA4FF4DC9
            A4FF4DC9A4FF4DC9A3FF4CC8A3FF4CC8A3FF4BC8A2FF4AC7A1FF4BC8A2FF51CA
            A6FF3C8B6EFF0F271E6900000005000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000034317DBD5B66D4FF576C
            E2FF5167E3FF5065E2FF4F64E1FF4E63E1FF4D62E1FF4C61E0FF4B60E0FF4B5F
            DFFF4A5EDFFF4E61E0FF525ACFFF2D2876BF0000000A00000000000000000000
            00000000000000000000215281BD60A9DDFF6CC2F0FF66BEEFFF65BEEEFF63BC
            EFFF62BCEDFF61BBEEFF60BAEDFF5FB9EDFF5DB8ECFF5CB8ECFF61BAEDFF55A0
            D9FF1E497CBF0000000A00000000000000000000000000000000000000002457
            43BD52B495FF56CDA9FF50CBA7FF51CBA6FF50CBA5FF4FCAA5FF4FC9A5FF4EC9
            A5FF4EC9A4FF4DC8A3FF4CC8A3FF50CAA4FF4DB091FF215240BF0000000A0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000004844A7ED6273E1FF596DE4FF556BE3FF5469E2FF5469E2FF5368
            E2FF5167E3FF5166E2FF5065E2FF4F64E2FF4E63E1FF4F64E2FF5768DDFF3F38
            9EEB0000000B00000000000000000000000000000000000000002E70AAED72C1
            EBFF6EC5F1FF6BC2F0FF6AC2F0FF68C0EFFF67BFEFFF66BEEFFF64BEEFFF63BD
            EEFF62BCEEFF61BBEDFF62BBEDFF65B7E9FF2963A2EB0000000B000000000000
            00000000000000000000000000002E7359ED5CC9A9FF55CEAAFF53CDA9FF52CD
            A8FF52CCA8FF52CCA7FF51CBA7FF50CAA6FF4FCBA6FF4FCAA6FF4FCAA5FF50CB
            A5FF56C6A5FF2B6E55EB0000000B000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000005451BCFF6B81E7FF5B70
            E5FF5A70E5FF596FE4FF586DE4FF576DE4FF566BE3FF566BE3FF556AE2FF5368
            E4FF5368E2FF5267E1FF6276E5FF4945AFFA0000000B00000000000000000000
            00000000000000000000367FBFFF81CDF3FF70C6F1FF70C6F1FF6EC5F1FF6DC4
            F0FF6CC3F1FF6AC2F0FF69C1EFFF68C1F0FF67BFEFFF65BFEFFF64BDEEFF72C4
            F0FF2E72B2FA0000000B00000000000000000000000000000000000000003681
            65FF68D3B5FF56CEABFF56CEABFF55CDABFF55CDABFF54CDAAFF53CDAAFF53CC
            A8FF52CCA8FF51CCA8FF51CBA7FF51CAA7FF61CFB0FF307A5CFA0000000B0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000005151B0EC7C8DE8FF6177E6FF5F74E6FF5E73E6FF5C72E6FF5B70
            E5FF5B70E5FF5A6FE5FF596EE4FF586DE4FF576CE4FF586DE3FF7283E5FF4844
            A6EA0000000A00000000000000000000000000000000000000003579B2EC89CF
            F1FF77CCF3FF74C9F3FF73C9F2FF71C8F2FF70C7F2FF6FC5F1FF6EC5F1FF6DC4
            F1FF6BC3F1FF6BC2F0FF6BC2F0FF7EC6EDFF2E6DAAEA0000000A000000000000
            000000000000000000000000000034775EEC73D2B7FF59D0AEFF58CFADFF57CF
            ADFF57CFADFF57CFABFF55CEACFF56CEABFF55CEABFF54CDAAFF53CDA9FF54CE
            A9FF6DCFB2FF2F735AEA0000000A000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000042428BBA858FE2FF697E
            E9FF6378E8FF6277E8FF6277E7FF6176E7FF6075E6FF5E74E6FF5E73E6FF5D72
            E5FF5B70E6FF5F75E6FF7C87DDFF3C3A85BC0000000700000000000000000000
            000000000000000000002A628DBA85C4E7FF7ED0F4FF79CDF4FF78CCF4FF77CB
            F4FF75CBF3FF74CAF3FF72C8F3FF72C7F2FF70C7F1FF6FC6F2FF73C7F2FF7BBC
            E4FF265A88BC000000070000000000000000000000000000000000000000275F
            4ABA73C3ACFF60D2B2FF5AD0AFFF59D0AEFF59D0AEFF59D0AEFF58D0AEFF57CF
            ACFF57CFADFF56CEABFF56CEABFF5ACFADFF6FC0A8FF265B48BC000000070000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000232347627277D3FF889BEFFF697EE8FF657BE9FF657AE8FF6578
            E8FF6379E8FF6378E7FF6278E7FF6176E8FF6278E7FF8194EEFF6C6ECEFF1F1E
            4262000000030000000000000000000000000000000000000000163347625CA4
            D6FF9CDDF9FF7FD2F5FF7DCFF5FF7BCFF5FF7ACEF4FF79CDF4FF78CCF4FF76CB
            F3FF75CAF2FF76CAF3FF91D6F6FF559CD0FF142E426200000003000000000000
            000000000000000000000000000015302662539F86FF7DDDC4FF5DD3B2FF5BD2
            B0FF5BD2B0FF5BD1B0FF5AD1B0FF5AD0AFFF59D0AEFF59D0AEFF59D1ADFF79DA
            C0FF509C82FF132D236200000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000010102095152A2D08E97
            E3FF8FA0EFFF6C82E9FF687EE9FF687DE9FF677CEAFF667CEAFF657BE9FF687D
            E8FF899BEFFF8891E1FF414185B5000000070000000100000000000000000000
            00000000000000000000010202093376A2D088C6E7FFA2E1F9FF84D4F6FF7FD3
            F6FF7ED2F6FF7DD1F5FF7CD0F5FF7ACFF5FF7CCFF4FF9ADBF8FF82C1E4FF2860
            88B5000000070000000100000000000000000000000000000000000000000102
            01092E6F59D077C2ACFF84DFC7FF60D3B4FF5DD2B2FF5DD3B2FF5DD2B1FF5CD2
            B1FF5CD1B0FF5DD2B1FF81DEC4FF74BFAAFF265C48B500000007000000010000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000010F0F1D2A5F62BBEA8992E1FFA1B1F2FF8397EEFF7389
            EBFF6A80EAFF7286EBFF8194EDFF9FAEF2FF868EDFFF5A5BB8E9090913200000
            0002000000000000000000000000000000000000000000000000000000010916
            1D2A3D8CBCEA7EC1E5FFB2E6F9FF98DEF8FF8AD8F7FF82D4F6FF89D6F6FF94DB
            F7FFADE3F9FF7ABCE2FF3A84B9E9060E13200000000200000000000000000000
            0000000000000000000000000000000000010914102A3B8169EA6FBAA3FF97E4
            D0FF78DCC1FF66D7B7FF5FD4B3FF65D6B6FF77DBBFFF94E3CFFF6DB8A2FF377C
            65E9060D0A200000000200000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010909
            111B494B8EB2777BD7FF98A3E9FFA9B5F2FFAFBEF5FFA7B5F2FF97A2E9FF7478
            D5FF45488CB30809111C00000002000000000000000000000000000000000000
            000000000000000000000000000000000001060D111B2D698EB259A9D9FF97D2
            EEFFB3E4F7FFC0ECFCFFB2E3F7FF95D0EDFF58A7D7FF2D668CB3050C111C0000
            0002000000000000000000000000000000000000000000000000000000000000
            000000000001050C091B2A604DB2509E84FF84CCB7FF9AE1CFFFA5EBDAFF9AE1
            CFFF82CCB7FF4F9D83FF295F4CB3050C091C0000000200000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000320213E5040427B9B5556
            A6CC686BCCF95456A5CC3F407B9B1F203D510000000400000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000100000003142E3E50285C7B9B367CA6CC4198CCF9367CA6CC285C
            7B9B142D3D510000000400000001000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000100000003122A
            22502454439B31705ACC3D8B6EF931705ACC2454439B122A2251000000040000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3TrafficLights1'
        end
        object dxRibbonGalleryItemIconSetsGroup3Item3: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000007000000100000
            0013000000140000001400000015000000150000001500000015000000160000
            0016000000160000001500000012000000080000000200000000000000000000
            0000000000000000000000000007000000100000001300000014000000140000
            0015000000150000001500000015000000160000001600000016000000150000
            0012000000080000000200000000000000000000000000000000000000000000
            0007000000100000001300000014000000140000001500000015000000150000
            0015000000160000001600000016000000150000001200000008000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000100B0A5E2B1E17EC2F211AFF2F201BFF2F211AFF2F201AFF2F20
            1AFF2F2019FF2F201AFF2F201AFF2F201AFF2F2019FF2F201AFF2A1D16ED0E0A
            0862000000080000000000000000000000000000000000000000100B0A5E2B1E
            17EC2F211AFF2F201BFF2F211AFF2F201AFF2F201AFF2F2019FF2F201AFF2F20
            1AFF2F201AFF2F2019FF2F201AFF2A1D16ED0E0A086200000008000000000000
            0000000000000000000000000000100B0A5E2B1E17EC2F211AFF2F201BFF2F21
            1AFF2F201AFF2F201AFF2F2019FF2F201AFF2F201AFF2F201AFF2F2019FF2F20
            1AFF2A1D16ED0E0A086200000008000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000033271FEA54423AFF513F
            35FF513E36FF503E35FF503E35FF503E35FF503E34FF4F3E34FF4F3E34FF4F3D
            34FF4F3D34FF4F3D34FF46352DFF2E1F1BEB0000001000000000000000000000
            0000000000000000000033271FEA54423AFF513F35FF513E36FF503E35FF503E
            35FF503E35FF503E34FF4F3E34FF4F3E34FF4F3D34FF4F3D34FF4F3D34FF4635
            2DFF2E1F1BEB0000001000000000000000000000000000000000000000003327
            1FEA54423AFF513F35FF513E36FF503E35FF503E35FF503E35FF503E34FF4F3E
            34FF4F3E34FF4F3D34FF4F3D34FF4F3D34FF46352DFF2E1F1BEB000000100000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000003E2D26FF645249FF4C3830FF4C3830FF4C3D45FF4B4D94FF4B58
            C6FF4B5BD6FF4B58C6FF4B4D93FF4A3C45FF4A372FFF49362EFF4F3D34FF3727
            21FF0000001300000000000000000000000000000000000000003E2D26FF6452
            49FF4C3830FF4C3830FF4D4748FF507F9FFF52A4D7FF53AFE9FF52A3D8FF4F7F
            9FFF4B4747FF4A372FFF49362EFF4F3D34FF372721FF00000013000000000000
            00000000000000000000000000003E2D26FF645249FF4C3830FF4C3830FF4F4A
            3FFF598A75FF60B498FF62C1A3FF60B498FF588A75FF4D493EFF4A372FFF4936
            2EFF4F3D34FF372721FF00000013000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000412F28FF67534BFF4E3A
            32FF4B425DFF3A48C7FF2F3ECAFF2C3BC9FF2F3ECAFF3848CEFF4757D4FF4B59
            CEFF4B415DFF4A372FFF503E35FF3A2923FF0000001300000000000000000000
            00000000000000000000412F28FF67534BFF4E3A32FF4D5963FF419CDCFF369A
            E2FF3398E1FF369AE2FF40A1E4FF4EACE8FF53A9E0FF4D5762FF4A372FFF503E
            35FF3A2923FF000000130000000000000000000000000000000000000000412F
            28FF67534BFF4E3A32FF515E4FFF4BAE8CFF40AD88FF3CAB85FF40AD88FF4BB4
            91FF5DBF9FFF61BB9EFF515C4FFF4A372FFF503E35FF3A2923FF000000130000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000044322BFF69564EFF4E3E47FF3C49C8FF3A4ACEFF3749CEFF3544
            CDFF303ECAFF2C3BC9FF2D3DCAFF4352D2FF4B59CEFF4C3D45FF513E35FF3C2C
            25FF00000012000000000000000000000000000000000000000044322BFF6956
            4EFF4E4849FF3997DAFF3B9EE3FF3DA0E3FF3B9EE3FF379BE2FF3398E1FF3499
            E1FF4AA8E6FF53A9E0FF4D4747FF513E35FF3C2C25FF00000012000000000000
            000000000000000000000000000044322BFF69564EFF504B40FF41AB86FF3EB0
            89FF3EAF89FF3EAF88FF3DAC86FF3CAB85FF3EAC86FF57BB9BFF61BB9EFF4F4A
            3EFF513E35FF3C2C25FF00000012000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000046342DFF6C5850FF4A4A
            91FF4B5AD3FF4D5DD4FF4A5BD3FF4454D1FF3C4CCFFF3343CBFF2C3BC9FF2D3D
            CAFF4757D4FF4C4D92FF523F36FF3F2E27FF0000001100000000000000000000
            0000000000000000000046342DFF6C5850FF46779BFF48A7E6FF50AEE7FF53AF
            E9FF50AEE7FF48A7E6FF3C9FE4FF3398E1FF3499E1FF4EACE8FF517E9DFF523F
            36FF3F2E27FF0000001100000000000000000000000000000000000000004634
            2DFF6C5850FF488369FF42B58FFF43B790FF43B690FF41B48EFF3FB18AFF3DAE
            88FF3CAB85FF3EAC86FF5DBF9FFF598974FF523F36FF3F2E27FF000000110000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000048362FFF6E5B53FF5762C6FF6477DCFF7E97E7FF86A3EBFF7690
            E6FF5567D7FF3F4FD0FF3343CCFF2C3BC9FF3948CEFF4B58C5FF534138FF4330
            2AFF00000010000000000000000000000000000000000000000048362FFF6E5B
            53FF4D9FD4FF63BBECFF87D5F4FF93DFF7FF87D6F4FF66BEEDFF4DABE7FF3DA0
            E4FF3398E1FF40A1E4FF52A3D6FF534138FF43302AFF00000010000000000000
            000000000000000000000000000048362FFF6E5B53FF45AC8AFF4EC19DFF67D5
            B7FF70DCC1FF65D3B5FF4BBD9AFF40B28CFF3DAE88FF3CAB85FF4CB491FF60B3
            97FF534138FF43302AFF00000010000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000004B3831FF725F57FF6A7A
            D9FF8FA9ECFF9CB9F0FF99B7F0FF91AEEDFF83A2EBFF5467D7FF3C4DCFFF303E
            CAFF2F3FCAFF4B5AD2FF544139FF45332CFF0000000F00000000000000000000
            000000000000000000004B3831FF725F57FF5DB4E7FF8FDBF5FFA6E8F9FFACEB
            FAFFA7E8F9FF97E1F7FF66BEEDFF48A7E6FF379AE1FF369AE2FF53ACE5FF5441
            39FF45332CFF0000000F00000000000000000000000000000000000000004B38
            31FF725F57FF4BBE9AFF6CDABEFF79E2CAFF7BE2CAFF77E0C8FF70DBC1FF4CBE
            9AFF3FB18BFF3DAC86FF40AD88FF62BEA0FF544139FF45332CFF0000000F0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000004D3A32FF746159FF7886D1FFA7C1F2FFADC6F4FFA9C3F3FF9FBB
            F1FF91ADEDFF7691E6FF4454D1FF3444CCFF2D3CC9FF4B58C5FF554239FF4835
            2EFF0000000E00000000000000000000000000000000000000004D3A32FF7461
            59FF68B2DAFFA4E7F9FFB7F1FCFFBEF5FDFFB7F1FCFFA6E9F9FF87D7F4FF50AD
            E8FF3B9EE3FF3499E1FF53A3D6FF554239FF48352EFF0000000E000000000000
            00000000000000000000000000004D3A32FF746159FF50B998FF7BE4CBFF82E7
            D1FF84E7D2FF7FE4CDFF77E0C8FF65D3B5FF41B48EFF3EAE88FF3DAC86FF60B3
            97FF554239FF48352EFF0000000E000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000004F3B34FF76635CFF7374
            9CFFAFC4F3FFBAD2F6FFB5CDF5FFA9C3F3FF99B7F0FF84A2EBFF4B5BD2FF3948
            CDFF2F3FCAFF4E4E92FF57433AFF4A372FFF0000000D00000000000000000000
            000000000000000000004F3B34FF76635CFF648CA1FFA3E7F9FFBEF5FDFFCBFB
            FFFFBEF4FDFFACEBFAFF93DEF7FF53B0E9FF3D9FE3FF369AE2FF527E9DFF5743
            3AFF4A372FFF0000000D00000000000000000000000000000000000000004F3B
            34FF76635CFF559078FF78E2C8FF87EAD6FF8AEAD7FF83E7D2FF7BE2CAFF6FDB
            C0FF44B690FF3EAF89FF40AD88FF5B8974FF57433AFF4A372FFF0000000D0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000503C35FF79665DFF5C4C4EFF9FAFE5FFC2D8F8FFBAD2F7FFADC6
            F4FF9BB9F1FF7E99E7FF4D5DD3FF3A49CEFF3A48C5FF514149FF58443BFF4C39
            31FF0000000C0000000000000000000000000000000000000000503C35FF7966
            5DFF57504EFF89CEEAFFB6F1FCFFBFF5FDFFB7F1FBFFA6E9F9FF86D6F4FF50AE
            E8FF3B9EE3FF419CDAFF524B4BFF58443BFF4C3931FF0000000C000000000000
            0000000000000000000000000000503C35FF79665DFF555146FF64CEB1FF86EB
            D6FF87EAD6FF82E7D1FF7AE2CAFF67D5B7FF42B790FF3EB089FF4CAE8DFF544D
            43FF58443BFF4C3931FF0000000C000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000513E36FF7B6861FF5641
            3AFF685D69FFA0B0E8FFAEC4F3FFA7C1F2FF8FA8ECFF6477DDFF4A5AD3FF3C49
            C8FF504561FF533E36FF58453EFF4E3A33FF0000000C00000000000000000000
            00000000000000000000513E36FF7B6861FF56413AFF5E666BFF89D1EBFFA3E6
            F9FFA5E8F9FF8FDAF5FF63BCECFF48A7E6FF3A98D9FF535C67FF533E36FF5845
            3EFF4E3A33FF0000000C0000000000000000000000000000000000000000513E
            36FF7B6861FF56413AFF576758FF64D0B2FF78E2C9FF7BE4CBFF6CD9BEFF4DC1
            9EFF42B68FFF41AB87FF566253FF533E36FF58453EFF4E3A33FF0000000C0000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000533E37FF7E6B63FF5F4A42FF57423AFF5D4D4FFF7476A0FF7884
            CFFF6B7BDDFF5863C4FF4D4D94FF54434AFF554038FF544038FF5A463EFF503C
            34FF0000000A0000000000000000000000000000000000000000533E37FF7E6B
            63FF5F4A42FF57423AFF59514FFF658EA4FF68B2D9FF5EB8EAFF4E9FD3FF487A
            9FFF544C4CFF554038FF544038FF5A463EFF503C34FF0000000A000000000000
            0000000000000000000000000000533E37FF7E6B63FF5F4A42FF57423AFF5752
            47FF55937BFF52B798FF4BC19CFF47AB89FF4A876CFF554F44FF554038FF5440
            38FF5A463EFF503C34FF0000000A000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000004B3A32E9725F57FF806D
            64FF7E6B64FF7E6B64FF7E6A63FF7D6962FF7C6962FF7C6961FF7B6760FF7A67
            61FF7A675FFF79675EFF6C5A52FF483630EA0000000800000000000000000000
            000000000000000000004B3A32E9725F57FF806D64FF7E6B64FF7E6B64FF7E6A
            63FF7D6962FF7C6962FF7C6961FF7B6760FF7A6761FF7A675FFF79675EFF6C5A
            52FF483630EA0000000800000000000000000000000000000000000000004B3A
            32E9725F57FF806D64FF7E6B64FF7E6B64FF7E6A63FF7D6962FF7C6962FF7C69
            61FF7B6760FF7A6761FF7A675FFF79675EFF6C5A52FF483630EA000000080000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000015100E4642322CCC543F38FF543F38FF543F38FF543F38FF533F
            37FF533F37FF533F37FF533F37FF533E37FF523E37FF523E36FF41302BCE140F
            0D4900000003000000000000000000000000000000000000000015100E464232
            2CCC543F38FF543F38FF543F38FF543F38FF533F37FF533F37FF533F37FF533F
            37FF533E37FF523E37FF523E36FF41302BCE140F0D4900000003000000000000
            000000000000000000000000000015100E4642322CCC543F38FF543F38FF543F
            38FF543F38FF533F37FF533F37FF533F37FF533F37FF533E37FF523E37FF523E
            36FF41302BCE140F0D4900000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '3TrafficLights2'
        end
        object dxRibbonGalleryItemIconSetsGroup3Item4: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            00000000000100000004000000070000000A0000000B0000000A000000080000
            0004000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000070000
            000D0000001100000012000000110000000D0000000700000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000070000000D00000011000000120000
            00110000000D0000000700000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000070000000D0000001100000012000000110000000D000000070000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002000000080F0B0960211512BD291D
            16ED2E1F19FF291D16ED201512BD0F0A08610000000900000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000040000000D34252069705044C2906558EF9D7060FF8F6456EF6E4D
            43C234241F6A0000000E00000004000000010000000000000000000000000000
            00000000000000000000000000000000000000000001000000040000000D1510
            3D692D2181C2382BA9EF3E2FB8FF372AA8EF2B2081C2140F3C6A0000000E0000
            0004000000010000000000000000000000000000000000000000000000000000
            00000000000000000001000000040000000D09053B6915087EC2180BA3EF1D0C
            B2FF170AA2EF14087EC209043A6A0000000E0000000400000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000030403
            0220211813B635251EFF3F2E26FF45322AFF47332BFF453229FF3F2C25FF3323
            1DFF201511B70403022200000003000000000000000000000000000000000000
            0000000000000000000000000001000000050D0A08276F5045BCB0897CFFD7C0
            B5FFEADAD1FFF2E5DCFFEADAD1FFD6BFB4FFAE8677FF6B4C40BD0D0908290000
            0005000000010000000000000000000000000000000000000000000000000000
            00010000000506050F272E2680BC4A42C4FF5862DBFF6071E5FF6276E9FF5E6F
            E4FF565FD9FF453EC2FF2C217DBD05040F290000000500000001000000000000
            000000000000000000000000000000000000000000010000000503020F27170D
            7CBC201AC3FF1D2CE3FF1B34F4FF1B35FBFF1A31F4FF1B27E3FF1C16C1FF150A
            7ABD02010F290000000500000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000020705042E2E201AEA3E2D25FF49362DFF4A362DFF4836
            2DFF48352DFF48352CFF47352BFF47342CFF3B2B22FF2A1D18EA040302250000
            0002000000000000000000000000000000000000000000000000000000041711
            0F35977064EBCDB1A7FFF1E5DDFFF2E6DEFFF2E6DEFFF2E6DDFFF1E5DDFFF1E5
            DCFFF0E4DCFFCAAEA2FF906A5DEC0F0B092B0000000400000000000000000000
            0000000000000000000000000000000000040B091B35443BAEEB595ED6FF677A
            E9FF667AEAFF657AEAFF6579EAFF6478EAFF6377E9FF6276E8FF5458D3FF3F33
            A9EC0605122B0000000400000000000000000000000000000000000000000000
            00000000000405041A352219AAEB242EDCFF223FFBFF203DFCFF1F3CFBFF1F3A
            FBFF1E3AFBFF1D3AFAFF1D36F8FF1E27DAFF1E12A7EC0302112B000000040000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000100000A2A1E18D34231
            29FF4C3830FF4B382FFF4B372FFF4A372EFF4B362DFF49362DFF49362DFF4835
            2DFF48352DFF3E2D25FF201613B7000000080000000100000000000000000000
            000000000000000000000202011089685CD7D5BEB3FFF2E7E0FFF2E7E0FFF2E6
            E0FFF2E6DEFFF2E6DDFFF2E6DEFFF1E6DEFFF2E5DDFFF2E5DDFFD2B8ADFF6D4E
            43BB0000000D0000000100000000000000000000000000000000000000000101
            021042389FD76169DBFF6B7FEBFF6A7EEBFF697EEBFF687CEBFF687CEBFF677B
            EAFF667AEBFF6679EAFF6579EAFF5A60D8FF302882BB0000000D000000010000
            0000000000000000000000000000000000000100021023199AD72B38E3FF2A47
            FDFF2744FDFF2642FCFF2542FBFF2441FBFF2341FCFF2240FBFF213EFBFF213B
            FBFF212DE1FF190F7DBB0000000D000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000140E0B663C2C23FF4E3A32FF4E3A32FF4D3A31FF4C3931FF4C38
            30FF4B382FFF4B382FFF4B372EFF4A362EFF4A362DFF49362DFF372720FF110C
            096200000003000000000000000000000000000000000000000040312B6CBD9D
            90FFF3E9E1FFF2E7E1FFF2E7E1FFF2E7E0FFF2E7E0FFF2E6E0FFF2E7DEFFF2E7
            DEFFF1E6DDFFF2E6DDFFF2E6DDFFB69285FF3728236900000005000000000000
            0000000000000000000000000000201D496C5F5DD1FF6F83ECFF6E83ECFF6D81
            ECFF6C81EBFF6B80EBFF6B7FEBFF6A7EEBFF6A7EEAFF697DEBFF687CEBFF687B
            EBFF5552CCFF1A17426900000005000000000000000000000000000000000000
            0000120F476C3332D1FF2F4CFEFF2E4DFDFF2E4BFDFF2C49FCFF2C48FCFF2A48
            FDFF2A47FDFF2946FCFF2543FCFF2542FBFF2441FBFF2928CBFF0E0940690000
            0005000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000261C16B948352DFF503C
            33FF503C33FF503B33FF4F3A32FF4E3A32FF4D3A32FF4C3A31FF4D3930FF4B39
            2FFF4B382FFF4B372FFF433128FF241A15BB0000000600000000000000000000
            000000000000000000007D6057BDDCC7BEFFF3E9E2FFF3E9E1FFF3E9E2FFF3E9
            E1FFF3E7E1FFF3E7E0FFF3E7E0FFF2E6E0FFF2E6DEFFF2E6E0FFF2E7DEFFD7C1
            B7FF73554CBF0000000A0000000000000000000000000000000000000000423E
            90BD6D78E1FF7286ECFF7186ECFF7186ECFF7085ECFF6F83ECFF6E82EBFF6D82
            EBFF6C81EBFF6C80EBFF6B7FEBFF6B7FEBFF646EDEFF3A348ABF0000000A0000
            00000000000000000000000000000000000024218DBD3949EBFF3552FDFF3553
            FFFF3350FFFF324FFEFF304DFEFF2F4CFEFF2E4BFDFF2D4AFDFF2D48FCFF2C48
            FCFF2B45FDFF2D3BE7FF1F1887BF0000000A0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000037271FEC503D34FF523E36FF513D35FF503D34FF503C33FF503C
            34FF4F3B32FF4F3A32FF4E3A32FF4E3A31FF4D3A32FF4D3A30FF4A372EFF3022
            1CEA000000070000000000000000000000000000000000000000A58074EDEEE0
            DAFFF3EAE3FFF3EAE2FFF3E9E2FFF3EAE2FFF3E9E2FFF2E9E1FFF2E9E1FFF3E9
            E1FFF2E7E0FFF3E7E0FFF2E7DEFFEADBD4FF977164EB0000000B000000000000
            00000000000000000000000000005B56BFED7587EAFF768AEDFF7589EDFF7489
            ECFF7488EDFF7287EDFF7286EDFF7085ECFF7084ECFF6F84ECFF6F82ECFF6D82
            ECFF6C7DE8FF4F4AB6EB0000000B000000000000000000000000000000000000
            0000362EBCED3C55FAFF3C57FFFF3958FFFF3755FEFF3755FEFF3653FEFF3553
            FFFF3451FFFF3350FFFF324FFFFF304DFEFF2F4CFEFF2F48F7FF2B25B2EB0000
            000B000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000003D2C24FF534037FF5440
            37FF543F36FF533F36FF523F36FF523E35FF513E34FF513D35FF503C34FF503C
            33FF4F3B33FF4F3A32FF4D3A32FF36261EFA0000000800000000000000000000
            00000000000000000000B89284FFF5EAE4FFF5EBE5FFF3EBE3FFF3EBE3FFF3EA
            E3FFF3EAE2FFF3E9E2FFF3E9E2FFF3E9E2FFF3E9E1FFF3E9E1FFF2E7E1FFF2E6
            DFFFA77D71FA0000000B00000000000000000000000000000000000000006A67
            D4FF7D91EDFF798EEEFF788DEDFF778CEEFF768BEDFF768BEDFF7589EDFF7489
            ECFF7388ECFF7287ECFF7187ECFF7186ECFF7387EBFF5B56C7FA0000000B0000
            0000000000000000000000000000000000003F3BD1FF4561FEFF415EFFFF405E
            FFFF3E5CFFFF3D5AFFFF3C5AFFFF3A57FFFF3A57FFFF3956FEFF3855FFFF3653
            FEFF3552FDFF3753FEFF342EC2FA0000000B0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000392921EB544038FF554139FF554138FF544037FF544038FF543F
            37FF533F36FF523F36FF523E35FF513D35FF513D34FF503D34FF4E3931FF3325
            1DE9000000060000000000000000000000000000000000000000AB8A7EECF1E6
            E0FFF5EDE6FFF5EDE5FFF5EBE5FFF3EBE5FFF5EBE5FFF5EBE3FFF3EAE2FFF3EA
            E3FFF3EAE2FFF3EAE1FFF2E9E2FFEDE2DAFF9F786CEA0000000A000000000000
            00000000000000000000000000006766C4EC8494ECFF7C91EEFF7C90EEFF7B8F
            EEFF7A8FEEFF7A8EEEFF788DEDFF788CEEFF778CEDFF768AEDFF758AEDFF7489
            EDFF7B8CECFF5D56BEEA0000000A000000000000000000000000000000000000
            00003D3CC1EC526CFAFF4664FFFF4663FFFF4561FFFF4361FFFF415EFFFF415E
            FFFF405DFFFF3E5BFFFF3D5AFFFF3C59FFFF3A57FFFF435EFAFF3530B9EA0000
            000A000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000002D201BB8503C34FF5843
            3BFF58433AFF56423AFF564239FF564139FF554138FF544037FF544037FF543F
            36FF533F36FF533E36FF4A372FFF291E18B90000000500000000000000000000
            00000000000000000000876D64BAE4D4CDFFF6EDE6FFF6EDE6FFF5EDE6FFF5ED
            E5FFF5EDE5FFF5EBE5FFF3EBE5FFF5EAE5FFF3EBE3FFF5EAE3FFF3EAE2FFE0CD
            C6FF7D6158BC0000000700000000000000000000000000000000000000005252
            9BBA8995EAFF7F94EFFF7E93EEFF7E93EFFF7D92EEFF7C91EFFF7C90EEFF7B8F
            EEFF7A8FEEFF7A8EEEFF788DEEFF788CEEFF818CE7FF4C4A96BC000000070000
            000000000000000000000000000000000000323498BA5A6DF1FF4D6AFFFF4C68
            FFFF4B67FFFF4A66FFFF4965FFFF4764FFFF4563FFFF4561FFFF4360FFFF425F
            FFFF405EFFFF5060EFFF2E2B93BC000000070000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000018120E5F48352CFF59443CFF58443CFF58433BFF58433AFF5843
            3AFF57433AFF56423AFF564239FF554138FF554038FF544037FF433128FF150F
            0C5E00000002000000000000000000000000000000000000000044383362CEB3
            A8FFF8F1EEFFF5EEE7FFF5EEE7FFF6EDE7FFF5EEE6FFF5EDE6FFF5EDE5FFF5EB
            E6FFF5EBE5FFF5EBE3FFF7EEEBFFC7A89CFF3D312C6200000003000000000000
            00000000000000000000000000002B2B4E628287E3FF8DA1F1FF8296F0FF8196
            EFFF8095EFFF8094EFFF7F93EFFF7E93EEFF7E92EEFF7C91EEFF7B90EFFF869A
            F0FF7B7DDFFF2726496200000003000000000000000000000000000000000000
            00001B1B4E62555CE5FF5F7BFFFF506DFFFF4F6DFFFF4E6AFFFF4E68FFFF4C69
            FFFF4B68FFFF4A68FFFF4A66FFFF4866FFFF5571FFFF4E52E0FF181749620000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000001010006352820CE513E
            35FF5B473EFF5A463DFF5A453DFF59453CFF58443CFF58443BFF58433AFF5743
            3AFF57423AFF4D3A31FF2B1F1AB2000000040000000000000000000000000000
            00000000000000000000020202099D8276D0E3D3CBFFF8F3EFFFF6EFE9FFF6EE
            E9FFF6EEE7FFF5EDE7FFF5EDE6FFF5EDE6FFF5EDE6FFF8F0ECFFDFCDC5FF7E66
            5CB5000000070000000100000000000000000000000000000000000000000102
            03096467B3D0909BEBFF91A5F2FF859AF0FF8398EFFF8298F0FF8296F0FF8196
            EFFF8096EFFF8195EFFF8D9FF1FF8A94E9FF515194B500000007000000010000
            000000000000000000000000000000000000010103094041B3D06474F1FF6480
            FFFF5472FFFF526FFFFF526EFFFF526EFFFF516EFFFF4F6DFFFF4F6BFFFF5D79
            FFFF5D6DF0FF323294B500000007000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000010A070627403025E9513C34FF5B473EFF5C473FFF5C46
            3EFF5B463EFF5A453DFF5A443DFF58443CFF4D3A31FF3D2D23E80605041D0000
            0001000000000000000000000000000000000000000000000000000000011C18
            162AB5988CEADFCCC4FFF8F4F0FFF7F2EDFFF6EFEAFFF6EEE9FFF6EFEAFFF7F0
            EBFFF8F2EFFFDBC7BFFFAE8E81E9120E0D200000000200000000000000000000
            0000000000000000000000000000000000011313202A7679CEEA909AEAFF9AAC
            F3FF8DA2F1FF889CF0FF8499F0FF879BEFFF8C9FF1FF97AAF2FF8C95E9FF7072
            CAE90C0C15200000000200000000000000000000000000000000000000000000
            0000000000010C0C202A4B51CEEA6372F0FF708BFEFF607DFFFF5976FFFF5572
            FFFF5873FFFF5D7AFFFF6B85FEFF606DEEFF4649C8E907071520000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010604
            031930231CB14A372EFF554138FF5B463DFF5D473FFF5A453DFF544037FF4936
            2DFF2F211AB10604031A00000001000000000000000000000000000000000000
            000000000000000000000000000000000001110E0D1B877269B2D1B5AAFFE9DC
            D6FFF5EEEAFFFAF7F4FFF4EEEAFFE8DBD5FFCDB0A5FF856D64B3100D0C1C0000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000010B0B131B5B5E9BB28A90E6FF97A5EEFF9EAEF2FFA1B2F4FF9DAC
            F2FF96A2EEFF878CE4FF58589AB30B0B131C0000000200000000000000000000
            00000000000000000000000000000000000000000000000000010707131B3B3D
            9CB25D64E9FF6C80F6FF758CFCFF7791FFFF738CFCFF6B7EF6FF5960E7FF373A
            9AB30707131C0000000200000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000215100C4E291F19993829
            21CB44332AF9372921CB291D1799140F0C4F0000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000001000000033B322E5077645C9B9E857ACCC2A395F99E827ACC7562
            599B3A312C510000000400000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000032828
            43504E51869B6A6DB2CC8387DFF9696CB2CC4E51869B27284351000000040000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000031A1B44503235889B4548B5CC5559
            E1F94446B4CC3235879B191A4351000000040000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '4RedToBlack'
        end
        object dxRibbonGalleryItemIconSetsGroup3Item5: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            00000000000100000004000000070000000A0000000B0000000A000000080000
            0004000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000070000
            000D0000001100000012000000110000000D0000000700000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000001000000070000000D00000011000000120000
            00110000000D0000000700000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000070000000D0000001100000012000000110000000D000000070000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002000000080F0B0960211512BD291D
            16ED2E1F19FF291D16ED201512BD0F0A08610000000900000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0001000000040000000D100C3369231A6EC22B228EEF30249BFF2A218EEF2118
            6DC20F0C326A0000000E00000004000000010000000000000000000000000000
            00000000000000000000000000000000000000000001000000040000000D0B1C
            3669183B73C21C4C94EF2152A2FF1C4B94EF173871C20A1B356A0000000E0000
            0004000000010000000000000000000000000000000000000000000000000000
            00000000000000000001000000040000000D0E241B691E4D38C2256349EF296D
            51FF256348EF1D4D38C20D241A6A0000000E0000000400000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000030403
            0220211813B635251EFF3F2E26FF45322AFF47332BFF453229FF3F2C25FF3323
            1DFF201511B70403022200000003000000000000000000000000000000000000
            00000000000000000000000000010000000504040D27231D6CBC3934ABFF414C
            C9FF4557D8FF475ADEFF4454D8FF3F48C8FF3530A9FF211A6BBD04030D290000
            0005000000010000000000000000000000000000000000000000000000000000
            00010000000503070E27183C72BC2F6AB3FF4B98D4FF58ADE4FF5DB5EBFF57AB
            E3FF4895D4FF2D67B1FF153870BD03070E290000000500000001000000000000
            0000000000000000000000000000000000000000000100000005040907271D4D
            3ABC328063FF46AC8BFF4EC19DFF51CAA5FF4DC19CFF43AB89FF317F61FF1D49
            38BD040907290000000500000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000020705042E2E201AEA3E2D25FF49362DFF4A362DFF4836
            2DFF48352DFF48352CFF47352BFF47342CFF3B2B22FF2A1D18EA040302250000
            0002000000000000000000000000000000000000000000000000000000040807
            1735352D95EB444AC3FF4A5EDEFF455ADEFF4156DDFF3F53DCFF4054DDFF4257
            DCFF4657DCFF3E44C0FF302891EC05040F2B0000000400000000000000000000
            000000000000000000000000000000000004050E183525589CEB468ECDFF60B8
            EBFF5BB6ECFF58B3EAFF54B1EAFF55B1EAFF57B3EAFF59B3EAFF4189CAFF2051
            98EC0308102B0000000400000000000000000000000000000000000000000000
            00000000000406100C35296A51EB42A181FF51C9A4FF4DC8A2FF4AC7A0FF47C5
            9FFF49C6A0FF4CC7A1FF4FC8A2FF3F9F7EFF29674EEC040A082B000000040000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000000100000A2A1E18D34231
            29FF4C3830FF4B382FFF4B372FFF4A372EFF4B362DFF49362DFF49362DFF4835
            2DFF48352DFF3E2D25FF201613B7000000080000000100000000000000000000
            0000000000000000000001010210332D89D74C55CAFF5064E1FF485DDFFF4559
            DEFF4459DDFF4358DDFF4257DDFF4156DCFF4257DDFF485BDEFF434CC7FF2520
            6FBB0000000D0000000100000000000000000000000000000000000000000101
            021023538ED74F9BD5FF64BCEEFF5EB8ECFF5BB6ECFF59B5EBFF58B4EBFF57B4
            EBFF57B2EBFF57B3EAFF5CB5EBFF4894D1FF193E72BB0000000D000000010000
            00000000000000000000000000000000000001010110245F49D747AA8AFF53CB
            A7FF4DC8A3FF4BC8A1FF4AC7A1FF4AC7A1FF49C6A0FF49C69FFF4AC7A1FF50C9
            A3FF43A686FF1D4C3ABB0000000D000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000140E0B663C2C23FF4E3A32FF4E3A32FF4D3A31FF4C3931FF4C38
            30FF4B382FFF4B382FFF4B372EFF4A362EFF4A362DFF49362DFF372720FF110C
            096200000003000000000000000000000000000000000000000019163F6C4E4D
            BBFF566BE3FF4E64E0FF4C61E0FF4A5FDFFF4A5EDFFF485EDFFF485DDFFF475C
            DEFF445ADEFF465BDEFF4C61DFFF4544B5FF1511386900000005000000000000
            00000000000000000000000000001027416C4082C1FF6CC1EFFF64BCEDFF60BA
            EDFF5FB9EDFF5EB8ECFF5DB7ECFF5CB6ECFF5BB6ECFF59B5EBFF5BB5EBFF60B9
            EBFF3B79BCFF0E213A6900000005000000000000000000000000000000000000
            0000122C216C3F8E72FF57CDAAFF4FCAA4FF4DC9A4FF4DC9A4FF4DC9A3FF4CC8
            A3FF4CC8A3FF4BC8A2FF4AC7A1FF4BC8A2FF51CAA6FF3C8B6EFF0F271E690000
            0005000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000261C16B948352DFF503C
            33FF503C33FF503B33FF4F3A32FF4E3A32FF4D3A32FF4C3A31FF4D3930FF4B39
            2FFF4B382FFF4B372FFF433128FF241A15BB0000000600000000000000000000
            0000000000000000000034317DBD5B66D4FF576CE2FF5167E3FF5065E2FF4F64
            E1FF4E63E1FF4D62E1FF4C61E0FF4B60E0FF4B5FDFFF4A5EDFFF4E61E0FF525A
            CFFF2D2876BF0000000A00000000000000000000000000000000000000002152
            81BD60A9DDFF6CC2F0FF66BEEFFF65BEEEFF63BCEFFF62BCEDFF61BBEEFF60BA
            EDFF5FB9EDFF5DB8ECFF5CB8ECFF61BAEDFF55A0D9FF1E497CBF0000000A0000
            000000000000000000000000000000000000245743BD52B495FF56CDA9FF50CB
            A7FF51CBA6FF50CBA5FF4FCAA5FF4FC9A5FF4EC9A5FF4EC9A4FF4DC8A3FF4CC8
            A3FF50CAA4FF4DB091FF215240BF0000000A0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000037271FEC503D34FF523E36FF513D35FF503D34FF503C33FF503C
            34FF4F3B32FF4F3A32FF4E3A32FF4E3A31FF4D3A32FF4D3A30FF4A372EFF3022
            1CEA0000000700000000000000000000000000000000000000004844A7ED6273
            E1FF596DE4FF556BE3FF5469E2FF5469E2FF5368E2FF5167E3FF5166E2FF5065
            E2FF4F64E2FF4E63E1FF4F64E2FF5768DDFF3F389EEB0000000B000000000000
            00000000000000000000000000002E70AAED72C1EBFF6EC5F1FF6BC2F0FF6AC2
            F0FF68C0EFFF67BFEFFF66BEEFFF64BEEFFF63BDEEFF62BCEEFF61BBEDFF62BB
            EDFF65B7E9FF2963A2EB0000000B000000000000000000000000000000000000
            00002E7359ED5CC9A9FF55CEAAFF53CDA9FF52CDA8FF52CCA8FF52CCA7FF51CB
            A7FF50CAA6FF4FCBA6FF4FCAA6FF4FCAA5FF50CBA5FF56C6A5FF2B6E55EB0000
            000B000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000003D2C24FF534037FF5440
            37FF543F36FF533F36FF523F36FF523E35FF513E34FF513D35FF503C34FF503C
            33FF4F3B33FF4F3A32FF4D3A32FF36261EFA0000000800000000000000000000
            000000000000000000005451BCFF6B81E7FF5B70E5FF5A70E5FF596FE4FF586D
            E4FF576DE4FF566BE3FF566BE3FF556AE2FF5368E4FF5368E2FF5267E1FF6276
            E5FF4945AFFA0000000B0000000000000000000000000000000000000000367F
            BFFF81CDF3FF70C6F1FF70C6F1FF6EC5F1FF6DC4F0FF6CC3F1FF6AC2F0FF69C1
            EFFF68C1F0FF67BFEFFF65BFEFFF64BDEEFF72C4F0FF2E72B2FA0000000B0000
            000000000000000000000000000000000000368165FF68D3B5FF56CEABFF56CE
            ABFF55CDABFF55CDABFF54CDAAFF53CDAAFF53CCA8FF52CCA8FF51CCA8FF51CB
            A7FF51CAA7FF61CFB0FF307A5CFA0000000B0000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000392921EB544038FF554139FF554138FF544037FF544038FF543F
            37FF533F36FF523F36FF523E35FF513D35FF513D34FF503D34FF4E3931FF3325
            1DE90000000600000000000000000000000000000000000000005151B0EC7C8D
            E8FF6177E6FF5F74E6FF5E73E6FF5C72E6FF5B70E5FF5B70E5FF5A6FE5FF596E
            E4FF586DE4FF576CE4FF586DE3FF7283E5FF4844A6EA0000000A000000000000
            00000000000000000000000000003579B2EC89CFF1FF77CCF3FF74C9F3FF73C9
            F2FF71C8F2FF70C7F2FF6FC5F1FF6EC5F1FF6DC4F1FF6BC3F1FF6BC2F0FF6BC2
            F0FF7EC6EDFF2E6DAAEA0000000A000000000000000000000000000000000000
            000034775EEC73D2B7FF59D0AEFF58CFADFF57CFADFF57CFADFF57CFABFF55CE
            ACFF56CEABFF55CEABFF54CDAAFF53CDA9FF54CEA9FF6DCFB2FF2F735AEA0000
            000A000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000002D201BB8503C34FF5843
            3BFF58433AFF56423AFF564239FF564139FF554138FF544037FF544037FF543F
            36FF533F36FF533E36FF4A372FFF291E18B90000000500000000000000000000
            0000000000000000000042428BBA858FE2FF697EE9FF6378E8FF6277E8FF6277
            E7FF6176E7FF6075E6FF5E74E6FF5E73E6FF5D72E5FF5B70E6FF5F75E6FF7C87
            DDFF3C3A85BC0000000700000000000000000000000000000000000000002A62
            8DBA85C4E7FF7ED0F4FF79CDF4FF78CCF4FF77CBF4FF75CBF3FF74CAF3FF72C8
            F3FF72C7F2FF70C7F1FF6FC6F2FF73C7F2FF7BBCE4FF265A88BC000000070000
            000000000000000000000000000000000000275F4ABA73C3ACFF60D2B2FF5AD0
            AFFF59D0AEFF59D0AEFF59D0AEFF58D0AEFF57CFACFF57CFADFF56CEABFF56CE
            ABFF5ACFADFF6FC0A8FF265B48BC000000070000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000018120E5F48352CFF59443CFF58443CFF58433BFF58433AFF5843
            3AFF57433AFF56423AFF564239FF554138FF554038FF544037FF433128FF150F
            0C5E000000020000000000000000000000000000000000000000232347627277
            D3FF889BEFFF697EE8FF657BE9FF657AE8FF6578E8FF6379E8FF6378E7FF6278
            E7FF6176E8FF6278E7FF8194EEFF6C6ECEFF1F1E426200000003000000000000
            0000000000000000000000000000163347625CA4D6FF9CDDF9FF7FD2F5FF7DCF
            F5FF7BCFF5FF7ACEF4FF79CDF4FF78CCF4FF76CBF3FF75CAF2FF76CAF3FF91D6
            F6FF559CD0FF142E426200000003000000000000000000000000000000000000
            000015302662539F86FF7DDDC4FF5DD3B2FF5BD2B0FF5BD2B0FF5BD1B0FF5AD1
            B0FF5AD0AFFF59D0AEFF59D0AEFF59D1ADFF79DAC0FF509C82FF132D23620000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000001010006352820CE513E
            35FF5B473EFF5A463DFF5A453DFF59453CFF58443CFF58443BFF58433AFF5743
            3AFF57423AFF4D3A31FF2B1F1AB2000000040000000000000000000000000000
            00000000000000000000010102095152A2D08E97E3FF8FA0EFFF6C82E9FF687E
            E9FF687DE9FF677CEAFF667CEAFF657BE9FF687DE8FF899BEFFF8891E1FF4141
            85B5000000070000000100000000000000000000000000000000000000000102
            02093376A2D088C6E7FFA2E1F9FF84D4F6FF7FD3F6FF7ED2F6FF7DD1F5FF7CD0
            F5FF7ACFF5FF7CCFF4FF9ADBF8FF82C1E4FF286088B500000007000000010000
            000000000000000000000000000000000000010201092E6F59D077C2ACFF84DF
            C7FF60D3B4FF5DD2B2FF5DD3B2FF5DD2B1FF5CD2B1FF5CD1B0FF5DD2B1FF81DE
            C4FF74BFAAFF265C48B500000007000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000010A070627403025E9513C34FF5B473EFF5C473FFF5C46
            3EFF5B463EFF5A453DFF5A443DFF58443CFF4D3A31FF3D2D23E80605041D0000
            0001000000000000000000000000000000000000000000000000000000010F0F
            1D2A5F62BBEA8992E1FFA1B1F2FF8397EEFF7389EBFF6A80EAFF7286EBFF8194
            EDFF9FAEF2FF868EDFFF5A5BB8E9090913200000000200000000000000000000
            00000000000000000000000000000000000109161D2A3D8CBCEA7EC1E5FFB2E6
            F9FF98DEF8FF8AD8F7FF82D4F6FF89D6F6FF94DBF7FFADE3F9FF7ABCE2FF3A84
            B9E9060E13200000000200000000000000000000000000000000000000000000
            0000000000010914102A3B8169EA6FBAA3FF97E4D0FF78DCC1FF66D7B7FF5FD4
            B3FF65D6B6FF77DBBFFF94E3CFFF6DB8A2FF377C65E9060D0A20000000020000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000010604
            031930231CB14A372EFF554138FF5B463DFF5D473FFF5A453DFF544037FF4936
            2DFF2F211AB10604031A00000001000000000000000000000000000000000000
            0000000000000000000000000000000000010909111B494B8EB2777BD7FF98A3
            E9FFA9B5F2FFAFBEF5FFA7B5F2FF97A2E9FF7478D5FF45488CB30809111C0000
            0002000000000000000000000000000000000000000000000000000000000000
            000000000001060D111B2D698EB259A9D9FF97D2EEFFB3E4F7FFC0ECFCFFB2E3
            F7FF95D0EDFF58A7D7FF2D668CB3050C111C0000000200000000000000000000
            0000000000000000000000000000000000000000000000000001050C091B2A60
            4DB2509E84FF84CCB7FF9AE1CFFFA5EBDAFF9AE1CFFF82CCB7FF4F9D83FF295F
            4CB3050C091C0000000200000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000010000000215100C4E291F19993829
            21CB44332AF9372921CB291D1799140F0C4F0000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000010000000320213E5040427B9B5556A6CC686BCCF95456A5CC3F40
            7B9B1F203D510000000400000001000000000000000000000000000000000000
            000000000000000000000000000000000000000000000000000100000003142E
            3E50285C7B9B367CA6CC4198CCF9367CA6CC285C7B9B142D3D51000000040000
            0001000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000100000003122A22502454439B31705ACC3D8B
            6EF931705ACC2454439B122A2251000000040000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '4TrafficLights'
        end
      end
      object dxRibbonGalleryItemIconSetsGroup4: TdxRibbonGalleryGroup
        Header.Caption = 'Ratings'
        Header.Visible = True
        object dxRibbonGalleryItemIconSetsGroup4Item1: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000005000000080000
            0006000000030000000600000008000000060000000300000006000000080000
            0006000000030000000600000009000000060000000100000000000000000000
            0000000000000000000000000005000000080000000600000003000000060000
            0008000000060000000300000006000000080000000600000003000000060000
            0009000000060000000100000000000000000000000000000000000000000000
            0005000000080000000600000003000000060000000800000006000000030000
            0006000000080000000600000003000000060000000900000006000000010000
            0000000000000000000000000000000000000000000500000008000000060000
            0003000000060000000800000006000000030000000600000008000000060000
            0003000000060000000900000006000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000007A4C32BDA96946FF7A4C32BD0000000B7C5D52BDAB8074FF7C5C
            52BD0000000B7A5A52BDAB7F72FF7A5A52BD0000000C7A5A51BDAA7E71FF795B
            50BE0000000600000000000000000000000000000000000000007A4C32BDA969
            46FF7A4C32BD0000000B74482FBDA36442FF74482FBD0000000B7A5A52BDAB7F
            72FF7A5A52BD0000000C7A5A51BDAA7E71FF795B50BE00000006000000000000
            00000000000000000000000000007A4C32BDA96946FF7A4C32BD0000000B7448
            2FBDA36442FF74482FBD0000000B73432BBDA05D3BFF73432ABD0000000C7A5A
            51BDAA7E71FF795B50BE00000006000000000000000000000000000000000000
            00007A4C32BDA96946FF7A4C32BD0000000B74482FBDA36442FF74482FBD0000
            000B73432BBDA05D3BFF73432ABD0000000C71462FBD995738FF6E3F27BE0000
            0006000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000B27754FFFFB864FFB075
            51FF0000000FBE978BFFF3ECEAFFBD968BFF00000010BC9689FFF2EBE8FFBC95
            89FF00000010BC9489FFF2EAE7FFBC9488FF0000000900000000000000000000
            00000000000000000000B27754FFFFB864FFB07551FF0000000FB57C57FFE9B1
            6DFFB47B55FF00000010BC9689FFF2EBE8FFBC9589FF00000010BC9489FFF2EA
            E7FFBC9488FF000000090000000000000000000000000000000000000000B277
            54FFFFB864FFB07551FF0000000FB57C57FFE9B16DFFB47B55FF00000010B375
            50FFDFB279FFB27450FF00000010BC9489FFF2EAE7FFBC9488FF000000090000
            000000000000000000000000000000000000B27754FFFFB864FFB07551FF0000
            000FB57C57FFE9B16DFFB47B55FF00000010B37550FFDFB279FFB27450FF0000
            0010B47956FFE2B77FFFAC6D4AFF000000090000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000B57D59FFFFBC67FFB47A56FF0000000FBF9A8DFFF4EEEBFFBE99
            8DFF00000010BE988CFFF3ECEAFFBE988CFF00000010BE988BFFF2EBE9FFBE96
            8AFF000000090000000000000000000000000000000000000000B57D59FFFFBC
            67FFB47A56FF0000000FB77E59FFEAB470FFB67D58FF00000010BE988CFFF3EC
            EAFFBE988CFF00000010BE988BFFF2EBE9FFBE968AFF00000009000000000000
            0000000000000000000000000000B57D59FFFFBC67FFB47A56FF0000000FB77E
            59FFEAB470FFB67D58FF00000010B57954FFE0B57CFFB47753FF00000010BE98
            8BFFF2EBE9FFBE968AFF00000009000000000000000000000000000000000000
            0000B57D59FFFFBC67FFB47A56FF0000000FB77E59FFEAB470FFB67D58FF0000
            0010B57954FFE0B57CFFB47753FF00000010B57B59FFE3B981FFAD704DFF0000
            0009000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000B9835EFFFFBE6BFFB87F
            5BFF0000000EC19C90FFF4EFEDFFC09C8FFF0000000FC19B8FFFF4EEEBFFBF9A
            8EFF0000000FBF9A8EFFF3ECE9FFBF998DFF0000000800000000000000000000
            00000000000000000000B9835EFFFFBE6BFFB87F5BFF0000000EB8815BFFECB7
            73FFB87F5AFF0000000FC19B8FFFF4EEEBFFBF9A8EFF0000000FBF9A8EFFF3EC
            E9FFBF998DFF000000080000000000000000000000000000000000000000B983
            5EFFFFBE6BFFB87F5BFF0000000EB8815BFFECB773FFB87F5AFF0000000FB77C
            57FFE1B77EFFB77B56FF0000000FBF9A8EFFF3ECE9FFBF998DFF000000080000
            000000000000000000000000000000000000B9835EFFFFBE6BFFB87F5BFF0000
            000EB8815BFFECB773FFB87F5AFF0000000FB77C57FFE1B77EFFB77B56FF0000
            000FB8805DFFE3BB83FFAF734FFF000000080000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000BD8863FFFFD08CFFBA8560FF0000000DC39F93FFF5F0EEFFC29E
            93FF0000000EC29E92FFF5EFECFFC19C91FF0000000EC19C90FFF4EDEBFFC19C
            90FF000000080000000000000000000000000000000000000000BD8863FFFFD0
            8CFFBA8560FF0000000DBA835FFFEDB978FFBA835DFF0000000EC29E92FFF5EF
            ECFFC19C91FF0000000EC19C90FFF4EDEBFFC19C90FF00000008000000000000
            0000000000000000000000000000BD8863FFFFD08CFFBA8560FF0000000DBA83
            5FFFEDB978FFBA835DFF0000000EBA815BFFE3B882FFB97F5AFF0000000EC19C
            90FFF4EDEBFFC19C90FF00000008000000000000000000000000000000000000
            0000BD8863FFFFD08CFFBA8560FF0000000DBA835FFFEDB978FFBA835DFF0000
            000EBA815BFFE3B882FFB97F5AFF0000000EBA8461FFE4BC85FFB17652FF0000
            0008000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000967458C1CA9C76FF9674
            58C100000009C4A195FFF6F1EFFFC4A195FF0000000DC3A095FFF5F0EEFFC39F
            94FF0000000DC39F93FFF4EEECFFC29F92FF0000000700000000000000000000
            00000000000000000000967458C1CA9C76FF967458C100000009BC8661FFEEBB
            7DFFBB8560FF0000000DC3A095FFF5F0EEFFC39F94FF0000000DC39F93FFF4EE
            ECFFC29F92FF0000000700000000000000000000000000000000000000009674
            58C1CA9C76FF967458C100000009BC8661FFEEBB7DFFBB8560FF0000000DBD85
            60FFE3BB85FFBC845EFF0000000DC39F93FFF4EEECFFC29F92FF000000070000
            000000000000000000000000000000000000967458C1CA9C76FF967458C10000
            0009BC8661FFEEBB7DFFBB8560FF0000000DBD8560FFE3BB85FFBC845EFF0000
            000DBC8865FFE4BE87FFB37A55FF000000070000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000003000000050000000300000006C6A499FFF6F2F1FFC6A4
            98FF0000000CC6A397FFF6F1F0FFC6A296FF0000000CC4A195FFF5F0EDFFC4A1
            95FF000000070000000000000000000000000000000000000000000000030000
            00050000000300000006BE8964FFEFBF80FFBD8863FF0000000CC6A397FFF6F1
            F0FFC6A296FF0000000CC4A195FFF5F0EDFFC4A195FF00000007000000000000
            000000000000000000000000000000000003000000050000000300000006BE89
            64FFEFBF80FFBD8863FF0000000CC08A64FFE5BD89FFBF8863FF0000000CC4A1
            95FFF5F0EDFFC4A195FF00000007000000000000000000000000000000000000
            000000000003000000050000000300000006BE8964FFEFBF80FFBD8863FF0000
            000CC08A64FFE5BD89FFBF8863FF0000000CBF8C6AFFE5BF8AFFB67D59FF0000
            0007000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000005C8A79BFFF9F6F5FFC8A69BFF0000000AC7A59AFFF7F2F0FFC7A4
            99FF0000000BC6A498FFF6F1EFFFC6A497FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000005BF8C67FFF4CF
            9EFFBF8B65FF0000000AC7A59AFFF7F2F0FFC7A499FF0000000BC6A498FFF6F1
            EFFFC6A497FF0000000600000000000000000000000000000000000000000000
            0000000000000000000000000005BF8C67FFF4CF9EFFBF8B65FF0000000AC38E
            69FFE5C08CFFC28D67FF0000000BC6A498FFF6F1EFFFC6A497FF000000060000
            0000000000000000000000000000000000000000000000000000000000000000
            0005BF8C67FFF4CF9EFFBF8B65FF0000000AC38E69FFE5C08CFFC28D67FF0000
            000BC2906EFFE7C18DFFB8815CFF000000060000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000003977D75C0CAA99DFF967D
            75C000000008C9A89DFFF8F4F2FFC9A79CFF0000000AC9A79CFFF7F3F1FFC8A6
            9AFF000000050000000000000000000000000000000000000000000000000000
            000000000000000000038E694EC0C18D69FF8E694DC000000008C9A89DFFF8F4
            F2FFC9A79CFF0000000AC9A79CFFF7F3F1FFC8A69AFF00000005000000000000
            0000000000000000000000000000000000000000000000000000000000038E69
            4EC0C18D69FF8E694DC000000008C5926DFFE6C18FFFC4916CFF0000000AC9A7
            9CFFF7F3F1FFC8A69AFF00000005000000000000000000000000000000000000
            0000000000000000000000000000000000038E694EC0C18D69FF8E694DC00000
            0008C5926DFFE6C18FFFC4916CFF0000000AC49571FFE7C290FFBB8560FF0000
            0005000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000100000002000000040000000300000005CBAA9FFFF8F4F4FFCAA9
            9FFF00000009CAA99EFFF7F4F2FFCAA89DFF0000000500000000000000000000
            0000000000000000000000000000000000000000000000000001000000020000
            00040000000300000005CBAA9FFFF8F4F4FFCAA99FFF00000009CAA99EFFF7F4
            F2FFCAA89DFF0000000500000000000000000000000000000000000000000000
            000000000000000000000000000100000002000000040000000300000005C798
            71FFE7C492FFC7976FFF00000009CAA99EFFF7F4F2FFCAA89DFF000000050000
            0000000000000000000000000000000000000000000000000000000000000000
            000100000002000000040000000300000005C79871FFE7C492FFC7976FFF0000
            0009C69976FFE8C392FFBD8963FF000000050000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000004CDADA2FFFBF8F8FFCCACA1FF00000008CCACA0FFF8F4F3FFCCAC
            A0FF000000040000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000004CDADA2FFFBF8
            F8FFCCACA1FF00000008CCACA0FFF8F4F3FFCCACA0FF00000004000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000004C99B74FFEFD4ABFFC99B74FF00000008CCAC
            A0FFF8F4F3FFCCACA0FF00000004000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0004C99B74FFEFD4ABFFC99B74FF00000008C99D7AFFE9C494FFBF8C67FF0000
            0004000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000029A8279BFCFB0A5FF9982
            79BF00000006CEAEA3FFF9F6F5FFCDADA3FF0000000400000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000029A8279BFCFB0A5FF998279BF00000006CEAEA3FFF9F6
            F5FFCDADA3FF0000000400000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000029776
            58BFCC9F77FF977558BF00000006CEAEA3FFF9F6F5FFCDADA3FF000000040000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002977658BFCC9F77FF977558BF0000
            0006CBA17DFFE9C696FFC18F6AFF000000040000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000002000000030000000200000004CFB0A5FFFAF7F6FFCFB0
            A5FF000000030000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000020000
            00030000000200000004CFB0A5FFFAF7F6FFCFB0A5FF00000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002000000030000000200000004CFB0
            A5FFFAF7F6FFCFB0A5FF00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002000000030000000200000004CEA481FFE9C797FFC3936DFF0000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000003D1B3A8FFFCFAF9FFD1B3A8FF0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000003D1B3A8FFFCFA
            F9FFD1B3A8FF0000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000003D1B3A8FFFCFAF9FFD1B3A8FF000000030000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0003D0A785FFEFD5B0FFC59670FF000000030000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000019D877FBFD3B5ABFF9D85
            7EBF000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000019D877FBFD3B5ABFF9D857EBF00000002000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000019D87
            7FBFD3B5ABFF9D857EBF00000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000019C7E64BFD1AA88FF9A7C64BF0000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000000}
          ActionIndex = '4Rating'
        end
        object dxRibbonGalleryItemIconSetsGroup4Item2: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E00000000000000000000000000090000000E0000
            000F0000000F0000000F0000000E00000009000000050000000A0000000F0000
            001000000010000000100000000F0000000A0000000200000000000000000000
            00000000000000000000000000090000000E0000000F0000000F0000000F0000
            000E00000009000000050000000A0000000F0000001000000010000000100000
            000F0000000A0000000200000000000000000000000000000000000000000000
            00090000000E0000000F0000000F0000000F0000000E00000009000000050000
            000A0000000F0000001000000010000000100000000F0000000A000000020000
            000000000000000000000000000000000000000000090000000E0000000F0000
            000F0000000F0000000E00000009000000050000000A0000000F000000100000
            0010000000100000000F0000000A000000020000000000000000000000000000
            000000000000000000090000000E0000000F0000000F0000000F0000000E0000
            0009000000050000000A0000000F0000001000000010000000100000000F0000
            000A000000027B5C52C1AB8072FFAA7F71FFAA7F70FFAA7E70FFA97E6FFF785B
            4FC100000013724F43C19D6D5FFF9B6D5EFF9D6C5DFF9A6B5CFF9A6B5CFF6F4C
            42C10000000A00000000000000000000000000000000000000007A4C33C1A969
            46FFA96845FFA96744FFA86744FFA86644FF784930C100000013724F43C19D6D
            5FFF9B6D5EFF9D6C5DFF9A6B5CFF9A6B5CFF6F4C42C10000000A000000000000
            00000000000000000000000000007A4C33C1A96946FFA96845FFA96744FFA867
            44FFA86644FF784930C100000013754630C1A16241FFA16140FFA1603FFFA060
            3FFFA05F3FFF72432DC10000000A000000000000000000000000000000000000
            00007A4C33C1A96946FFA96845FFA96744FFA86744FFA86644FF784930C10000
            0013754630C1A16241FFA16140FFA1603FFFA0603FFFA05F3FFF72432DC10000
            000A00000000000000000000000000000000000000007A4C33C1A96946FFA968
            45FFA96744FFA86744FFA86644FF784930C100000013754630C1A16241FFA161
            40FFA1603FFFA0603FFFA05F3FFF72432DC10000000AB79081FFF9F2EEFFF8F2
            EEFFF7F2EDFFF7F0ECFFF7F1EDFFB48B7CFF0000001AAB7F6FFFF4EBE6FFF4EB
            E5FFF3E9E3FFF3E9E1FFF1E7E0FFA8796AFF0000000E00000000000000000000
            00000000000000000000B67A55FFE2BA86FFE2B984FFE2B882FFE1B780FFE0B6
            7FFFB37551FF0000001AAB7F6FFFF4EBE6FFF4EBE5FFF3E9E3FFF3E9E1FFF1E7
            E0FFA8796AFF0000000E0000000000000000000000000000000000000000B67A
            55FFE2BA86FFE2B984FFE2B882FFE1B780FFE0B67FFFB37551FF0000001AAF73
            4FFFDEB179FFDEAF77FFDEAE75FFDDAC73FFDCAB71FFAC6E4CFF0000000E0000
            000000000000000000000000000000000000B67A55FFE2BA86FFE2B984FFE2B8
            82FFE1B780FFE0B67FFFB37551FF0000001AAF734FFFDEB179FFDEAF77FFDEAE
            75FFDDAC73FFDCAB71FFAC6E4CFF0000000E0000000000000000000000000000
            000000000000B67A55FFE2BA86FFE2B984FFE2B882FFE1B780FFE0B67FFFB375
            51FF0000001AAF734FFFDEB179FFDEAF77FFDEAE75FFDDAC73FFDCAB71FFAC6E
            4CFF0000000EBA9284FFF9F5F1FFF7F0EBFFF6EFEBFFF7EFEBFFF9F3EFFFB68D
            7FFF0000001AAD8272FFF7F2EDFFF4ECE5FFF4EAE3FFF3E8E1FFF6EDE8FFAA7C
            6DFF0000000E0000000000000000000000000000000000000000B97F5AFFE7C3
            92FFE0B47DFFE0B37CFFE0B47DFFE5BF8DFFB67955FF0000001AAD8272FFF7F2
            EDFFF4ECE5FFF4EAE3FFF3E8E1FFF6EDE8FFAA7C6DFF0000000E000000000000
            0000000000000000000000000000B97F5AFFE7C392FFE0B47DFFE0B37CFFE0B4
            7DFFE5BF8DFFB67955FF0000001AB27854FFE3BB87FFDBA96DFFDBA86CFFDBA9
            6DFFE1B680FFAF724FFF0000000E000000000000000000000000000000000000
            0000B97F5AFFE7C392FFE0B47DFFE0B37CFFE0B47DFFE5BF8DFFB67955FF0000
            001AB27854FFE3BB87FFDBA96DFFDBA86CFFDBA96DFFE1B680FFAF724FFF0000
            000E0000000000000000000000000000000000000000B97F5AFFE7C392FFE0B4
            7DFFE0B37CFFE0B47DFFE5BF8DFFB67955FF0000001AB27854FFE3BB87FFDBA9
            6DFFDBA86CFFDBA96DFFE1B680FFAF724FFF0000000EBB9687FFFAF6F4FFF7F0
            ECFFF7F0ECFFF7F0ECFFFAF5F2FFB89082FF00000019B18576FFFAF7F4FFF6EF
            EAFFF6EFEAFFF4EFE8FFF8F3EEFFAC8071FF0000000D00000000000000000000
            00000000000000000000BD845FFFEBCB9FFFE2B983FFE3B984FFE3B983FFE9C7
            99FFB97E5AFF00000019B18576FFFAF7F4FFF6EFEAFFF6EFEAFFF4EFE8FFF8F3
            EEFFAC8071FF0000000D0000000000000000000000000000000000000000BD84
            5FFFEBCB9FFFE2B983FFE3B984FFE3B983FFE9C799FFB97E5AFF00000019B67D
            59FFE8C597FFDDAF74FFDFAF75FFDFAF74FFE6C08FFFB27754FF0000000D0000
            000000000000000000000000000000000000BD845FFFEBCB9FFFE2B983FFE3B9
            84FFE3B983FFE9C799FFB97E5AFF00000019B67D59FFE8C597FFDDAF74FFDFAF
            75FFDFAF74FFE6C08FFFB27754FF0000000D0000000000000000000000000000
            000000000000BD845FFFEBCB9FFFE2B983FFE3B984FFE3B983FFE9C799FFB97E
            5AFF00000019B67D59FFE8C597FFDDAF74FFDFAF75FFDFAF74FFE6C08FFFB277
            54FF0000000DBD998AFFFCF9F7FFF8F2EDFFF8F1EDFFF7F1EDFFFBF7F5FFB994
            84FF00000017B38979FFFDFAF8FFFAF4EFFFF8F4EFFFF8F1EDFFFBF7F5FFAF84
            75FF0000000D0000000000000000000000000000000000000000C08963FFEED2
            AAFFE5BE8AFFE6BD8AFFE5BD8BFFECCFA5FFBC835EFF00000017B38979FFFDFA
            F8FFFAF4EFFFF8F4EFFFF8F1EDFFFBF7F5FFAF8475FF0000000D000000000000
            0000000000000000000000000000C08963FFEED2AAFFE5BE8AFFE6BD8AFFE5BD
            8BFFECCFA5FFBC835EFF00000017B9825DFFECCEA4FFE1B47BFFE2B37BFFE1B3
            7CFFEAC99CFFB57C58FF0000000D000000000000000000000000000000000000
            0000C08963FFEED2AAFFE5BE8AFFE6BD8AFFE5BD8BFFECCFA5FFBC835EFF0000
            0017B9825DFFECCEA4FFE1B47BFFE2B37BFFE1B37CFFEAC99CFFB57C58FF0000
            000D0000000000000000000000000000000000000000C08963FFEED2AAFFE5BE
            8AFFE6BD8AFFE5BD8BFFECCFA5FFBC835EFF00000017B9825DFFECCEA4FFE1B4
            7BFFE2B37BFFE1B37CFFEAC99CFFB57C58FF0000000DBF9B8DFFFEFCFBFFFEFC
            FBFFFEFBFBFFFDFBFAFFFCFAF9FFBC9687FF00000014B58E7FFFFEFDFCFFFEFD
            FCFFFEFDFBFFFEFCFBFFFDFCFAFFB28878FF0000000B00000000000000000000
            00000000000000000000C28F68FFF4E4C8FFF4E2C5FFF4E1C3FFF3DFC1FFF3DE
            BEFFBF8963FF00000014B58E7FFFFEFDFCFFFEFDFCFFFEFDFBFFFEFCFBFFFDFC
            FAFFB28878FF0000000B0000000000000000000000000000000000000000C28F
            68FFF4E4C8FFF4E2C5FFF4E1C3FFF3DFC1FFF3DEBEFFBF8963FF00000014BC87
            62FFF4E1C4FFF4E0C1FFF2DEBEFFF2DDBDFFF1DBB9FFB8825DFF0000000B0000
            000000000000000000000000000000000000C28F68FFF4E4C8FFF4E2C5FFF4E1
            C3FFF3DFC1FFF3DEBEFFBF8963FF00000014BC8762FFF4E1C4FFF4E0C1FFF2DE
            BEFFF2DDBDFFF1DBB9FFB8825DFF0000000B0000000000000000000000000000
            000000000000C28F68FFF4E4C8FFF4E2C5FFF4E1C3FFF3DFC1FFF3DEBEFFBF89
            63FF00000014BC8762FFF4E1C4FFF4E0C1FFF2DEBEFFF2DDBDFFF1DBB9FFB882
            5DFF0000000B967F74C3C8A99DFFC8A79BFFC6A699FFC4A496FFC4A294FF9177
            6DC30000000D90776AC3C29D90FFBF9C8EFFBE998CFFBD9889FFBB9686FF8A6E
            64C400000007000000000000000000000000000000000000000097775FC3CCA0
            7FFFCB9E7BFFCB9D7AFFC99A77FFC79875FF947053C30000000D90776AC3C29D
            90FFBF9C8EFFBE998CFFBD9889FFBB9686FF8A6E64C400000007000000000000
            000000000000000000000000000097775FC3CCA07FFFCB9E7BFFCB9D7AFFC99A
            77FFC79875FF947053C30000000D947359C3C79978FFC69775FFC59673FFC493
            71FFC2916EFF8F6950C400000007000000000000000000000000000000000000
            000097775FC3CCA07FFFCB9E7BFFCB9D7AFFC99A77FFC79875FF947053C30000
            000D947359C3C79978FFC69775FFC59673FFC49371FFC2916EFF8F6950C40000
            0007000000000000000000000000000000000000000097775FC3CCA07FFFCB9E
            7BFFCB9D7AFFC99A77FFC79875FF947053C30000000D947359C3C79978FFC697
            75FFC59673FFC49371FFC2916EFF8F6950C4000000070000000B000000100000
            00110000001100000012000000110000000C000000060000000C000000120000
            00130000001300000013000000130000000D0000000300000000000000000000
            000000000000000000000000000B000000100000001100000011000000120000
            00110000000C000000060000000C000000120000001300000013000000130000
            00130000000D0000000300000000000000000000000000000000000000000000
            000B00000010000000110000001100000012000000110000000C000000060000
            000C00000012000000130000001300000013000000130000000D000000030000
            0000000000000000000000000000000000000000000B00000010000000110000
            001100000012000000110000000C000000060000000C00000012000000130000
            001300000013000000130000000D000000030000000000000000000000000000
            0000000000000000000B00000010000000110000001100000012000000110000
            000C000000060000000C00000012000000130000001300000013000000130000
            000D00000003826458BCB58A7BFFB4897AFFB4887AFFB48779FFB38677FF7F60
            56BD0000000B7A5C51BDA97E6FFFA87D6EFFA87C6DFFA77B6CFFA77A6BFF7757
            4CBD000000060000000000000000000000000000000000000000826458BCB58A
            7BFFB4897AFFB4887AFFB48779FFB38677FF7F6056BD0000000B7A5C51BDA97E
            6FFFA87D6EFFA87C6DFFA77B6CFFA77A6BFF77574CBD00000006000000000000
            0000000000000000000000000000826458BCB58A7BFFB4897AFFB4887AFFB487
            79FFB38677FF7F6056BD0000000B7A5C51BDA97E6FFFA87D6EFFA87C6DFFA77B
            6CFFA77A6BFF77574CBD00000006000000000000000000000000000000000000
            0000825339BCB5734DFFB5724CFFB5714BFFB4714BFFB4704BFF814F35BD0000
            000B7A5C51BDA97E6FFFA87D6EFFA87C6DFFA77B6CFFA77A6BFF77574CBD0000
            00060000000000000000000000000000000000000000825339BCB5734DFFB572
            4CFFB5714BFFB4714BFFB4704BFF814F35BD0000000B7F5137BDB1704AFFB16E
            49FFB16D48FFAF6D48FFAF6C48FF7D4E32BD00000006C19B8CFFF9F5F1FFF8F4
            F0FFF8F3EFFFF8F3EFFFF8F3EEFFBE9586FF0000000EB78F80FFF9F5F1FFF9F4
            F1FFF8F4F0FFF8F4F0FFF9F3EFFFB3897AFF0000000800000000000000000000
            00000000000000000000C19B8CFFF9F5F1FFF8F4F0FFF8F3EFFFF8F3EFFFF8F3
            EEFFBE9586FF0000000EB78F80FFF9F5F1FFF9F4F1FFF8F4F0FFF8F4F0FFF9F3
            EFFFB3897AFF000000080000000000000000000000000000000000000000C19B
            8CFFF9F5F1FFF8F4F0FFF8F3EFFFF8F3EFFFF8F3EEFFBE9586FF0000000EB78F
            80FFF9F5F1FFF9F4F1FFF8F4F0FFF8F4F0FFF9F3EFFFB3897AFF000000080000
            000000000000000000000000000000000000C1855DFFE5C08BFFE6BE8AFFE5BE
            88FFE5BD86FFE4BC85FFBE7F5AFF0000000EB78F80FFF9F5F1FFF9F4F1FFF8F4
            F0FFF8F4F0FFF9F3EFFFB3897AFF000000080000000000000000000000000000
            000000000000C1855DFFE5C08BFFE6BE8AFFE5BE88FFE5BD86FFE4BC85FFBE7F
            5AFF0000000EBD815AFFE2BA86FFE2B984FFE2B882FFE1B780FFE0B67FFFBA7C
            57FF00000008C49F91FFFBF7F4FFF8F3F0FFF8F3EEFFF8F2EEFFFAF5F1FFC199
            8AFF0000000EBA9384FFFBF7F5FFF8F4F0FFF8F4F0FFF8F4F0FFFAF6F3FFB58D
            7EFF000000080000000000000000000000000000000000000000C49F91FFFBF7
            F4FFF8F3F0FFF8F3EEFFF8F2EEFFFAF5F1FFC1998AFF0000000EBA9384FFFBF7
            F5FFF8F4F0FFF8F4F0FFF8F4F0FFFAF6F3FFB58D7EFF00000008000000000000
            0000000000000000000000000000C49F91FFFBF7F4FFF8F3F0FFF8F3EEFFF8F2
            EEFFFAF5F1FFC1998AFF0000000EBA9384FFFBF7F5FFF8F4F0FFF8F4F0FFF8F4
            F0FFFAF6F3FFB58D7EFF00000008000000000000000000000000000000000000
            0000C38A63FFE9C797FFE4BB84FFE4BA83FFE4BB84FFE8C492FFC1845DFF0000
            000EBA9384FFFBF7F5FFF8F4F0FFF8F4F0FFF8F4F0FFFAF6F3FFB58D7EFF0000
            00080000000000000000000000000000000000000000C38A63FFE9C797FFE4BB
            84FFE4BA83FFE4BB84FFE8C492FFC1845DFF0000000EBF865FFFE7C392FFE0B4
            7DFFE0B37CFFE0B47DFFE5BF8DFFBD805AFF00000008C6A395FFFCF9F8FFFAF4
            F1FFF9F5F1FFF9F4F0FFFAF8F5FFC39D8EFF0000000DBC9689FFFCFAF9FFF9F6
            F3FFF9F6F2FFF9F5F2FFFCF8F6FFB99182FF0000000700000000000000000000
            00000000000000000000C6A395FFFCF9F8FFFAF4F1FFF9F5F1FFF9F4F0FFFAF8
            F5FFC39D8EFF0000000DBC9689FFFCFAF9FFF9F6F3FFF9F6F2FFF9F5F2FFFCF8
            F6FFB99182FF000000070000000000000000000000000000000000000000C6A3
            95FFFCF9F8FFFAF4F1FFF9F5F1FFF9F4F0FFFAF8F5FFC39D8EFF0000000DBC96
            89FFFCFAF9FFF9F6F3FFF9F6F2FFF9F5F2FFFCF8F6FFB99182FF000000070000
            000000000000000000000000000000000000C78F68FFECCFA3FFE5C08AFFE6C0
            8BFFE6C08AFFEBCC9EFFC38963FF0000000DBC9689FFFCFAF9FFF9F6F3FFF9F6
            F2FFF9F5F2FFFCF8F6FFB99182FF000000070000000000000000000000000000
            000000000000C78F68FFECCFA3FFE5C08AFFE6C08BFFE6C08AFFEBCC9EFFC389
            63FF0000000DC38B65FFEBCB9FFFE2B983FFE3B984FFE3B983FFE9C799FFBF85
            5FFF00000007C9A799FFFDFBFAFFFAF7F4FFFAF6F3FFF9F6F2FFFCFAF8FFC6A1
            93FF0000000BBF9A8DFFFDFCFBFFFBF8F5FFFAF7F6FFFAF7F5FFFDFBFAFFBB94
            86FF000000060000000000000000000000000000000000000000C9A799FFFDFB
            FAFFFAF7F4FFFAF6F3FFF9F6F2FFFCFAF8FFC6A193FF0000000BBF9A8DFFFDFC
            FBFFFBF8F5FFFAF7F6FFFAF7F5FFFDFBFAFFBB9486FF00000006000000000000
            0000000000000000000000000000C9A799FFFDFBFAFFFAF7F4FFFAF6F3FFF9F6
            F2FFFCFAF8FFC6A193FF0000000BBF9A8DFFFDFCFBFFFBF8F5FFFAF7F6FFFAF7
            F5FFFDFBFAFFBB9486FF00000006000000000000000000000000000000000000
            0000C9956DFFEFD5AEFFE8C492FFE9C392FFE8C393FFEED2A9FFC68E67FF0000
            000BBF9A8DFFFDFCFBFFFBF8F5FFFAF7F6FFFAF7F5FFFDFBFAFFBB9486FF0000
            00060000000000000000000000000000000000000000C9956DFFEFD5AEFFE8C4
            92FFE9C392FFE8C393FFEED2A9FFC68E67FF0000000BC69069FFEED2AAFFE5BE
            8AFFE6BD8AFFE5BD8BFFECCFA5FFC28A64FF00000006CBAA9BFFFEFEFDFFFEFE
            FDFFFEFDFCFFFEFDFCFFFDFCFCFFC7A596FF00000009C29E91FFFEFEFEFFFEFE
            FDFFFEFEFDFFFEFEFDFFFEFCFCFFBD988AFF0000000500000000000000000000
            00000000000000000000CBAA9BFFFEFEFDFFFEFEFDFFFEFDFCFFFEFDFCFFFDFC
            FCFFC7A596FF00000009C29E91FFFEFEFEFFFEFEFDFFFEFEFDFFFEFEFDFFFEFC
            FCFFBD988AFF000000050000000000000000000000000000000000000000CBAA
            9BFFFEFEFDFFFEFEFDFFFEFDFCFFFEFDFCFFFDFCFCFFC7A596FF00000009C29E
            91FFFEFEFEFFFEFEFDFFFEFEFDFFFEFEFDFFFEFCFCFFBD988AFF000000050000
            000000000000000000000000000000000000CC9A72FFF5E5CAFFF5E3C8FFF5E2
            C6FFF5E2C4FFF3E0C1FFC9956DFF00000009C29E91FFFEFEFEFFFEFEFDFFFEFE
            FDFFFEFEFDFFFEFCFCFFBD988AFF000000050000000000000000000000000000
            000000000000CC9A72FFF5E5CAFFF5E3C8FFF5E2C6FFF5E2C4FFF3E0C1FFC995
            6DFF00000009C9966FFFF4E4C8FFF4E2C5FFF4E1C3FFF3DFC1FFF3DEBEFFC590
            69FF000000059D887FBFD3B7AAFFD2B5A8FFD1B4A7FFCFB2A5FFCFB1A3FF9981
            77C000000005978278C0CCAEA1FFCBAB9FFFCAA99DFFC8A79BFFC6A598FF9378
            6FC00000000300000000000000000000000000000000000000009D887FBFD3B7
            AAFFD2B5A8FFD1B4A7FFCFB2A5FFCFB1A3FF998177C000000005978278C0CCAE
            A1FFCBAB9FFFCAA99DFFC8A79BFFC6A598FF93786FC000000003000000000000
            00000000000000000000000000009D887FBFD3B7AAFFD2B5A8FFD1B4A7FFCFB2
            A5FFCFB1A3FF998177C000000005978278C0CCAEA1FFCBAB9FFFCAA99DFFC8A7
            9BFFC6A598FF93786FC000000003000000000000000000000000000000000000
            00009D7F64BFD5A988FFD4A884FFD4A783FFD2A480FFD1A27EFF9A775AC00000
            0005978278C0CCAEA1FFCBAB9FFFCAA99DFFC8A79BFFC6A598FF93786FC00000
            000300000000000000000000000000000000000000009D7F64BFD5A988FFD4A8
            84FFD4A783FFD2A480FFD1A27EFF9A775AC0000000059D7D63C0D1A684FFD1A5
            81FFD0A47FFFCEA17DFFCE9F7BFF977559C000000003}
          ActionIndex = '5Boxes'
        end
        object dxRibbonGalleryItemIconSetsGroup4Item3: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000000000000000000
            00000000000100000004000000070000000A0000000B0000000A000000080000
            0004000000010000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000040000
            00070000000A0000000B0000000A000000080000000400000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000100000004000000070000000A0000000B0000
            000A000000080000000400000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000100000004000000070000000A0000000B0000000A00000008000000040000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000100000004000000070000
            000A0000000B0000000A00000008000000040000000100000000000000000000
            000000000000000000000000000000000002000000080F0B0960211512BD291D
            16ED2E1F19FF291D16ED201512BD0F0A08610000000900000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002000000080F0B0960211512BD291D16ED2E1F19FF291D16ED2015
            12BD0F0A08610000000900000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000002000000080F0B
            0960211512BD291D16ED2E1F19FF291D16ED201512BD0F0A0861000000090000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000002000000080F0B0960211512BD291D16ED2E1F
            19FF291D16ED201512BD0F0A0861000000090000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0002000000080F0B0960211512BD291D16ED2E1F19FF291D16ED201512BD0F0A
            0861000000090000000300000000000000000000000000000001000000030403
            0220211813B6564943FFB7B0ADFFE7E3E0FFF9F6F5FFE7E3DFFFB6B0ACFF5447
            43FF201511B70403022200000003000000000000000000000000000000000000
            00000000000000000000000000010000000304030220211813B6574B45FFBBB6
            B4FFEBEAE9FFFFFFFFFFEBEAE9FFBAB5B4FF554945FF201511B7040302220000
            0003000000000000000000000000000000000000000000000000000000000000
            00010000000304030220211813B6574B45FFBBB6B4FFEBEAE9FF47332BFF4532
            29FF3F2C25FF33231DFF201511B7040302220000000300000000000000000000
            0000000000000000000000000000000000000000000100000003040302202118
            13B635251EFF3F2E26FF45322AFF47332BFF453229FF3F2C25FF33231DFF2015
            11B7040302220000000300000000000000000000000000000000000000000000
            000000000000000000010000000304030220211813B635251EFF3F2E26FF4532
            2AFF47332BFF453229FF3F2C25FF33231DFF201511B704030222000000030000
            000000000000000000020705042E32261EEA99918DFFF8F5F3FFFAF7F6FFFAF7
            F5FFF9F8F6FFFAF7F5FFF9F7F5FFF8F4F2FF988F8BFF30241CEA040302250000
            0002000000000000000000000000000000000000000000000000000000020705
            042E32261EEA9C9492FFFDFCFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFDFCFCFF9B9491FF30241CEA040302250000000200000000000000000000
            0000000000000000000000000000000000020705042E32261EEA9C9492FFFDFC
            FCFFFFFFFFFFFFFFFFFF48352DFF48352CFF47352BFF47342CFF3B2B22FF2A1D
            18EA040302250000000200000000000000000000000000000000000000000000
            0000000000020705042E2E201AEA3E2D25FF49362DFF4A362DFF48362DFF4835
            2DFF48352CFF47352BFF47342CFF3B2B22FF2A1D18EA04030225000000020000
            00000000000000000000000000000000000000000000000000020705042E2E20
            1AEA3E2D25FF49362DFF4A362DFF48362DFF48352DFF48352CFF47352BFF4734
            2CFF3B2B22FF2A1D18EA0403022500000002000000000100000A2A1E18D3ABA4
            A1FFFAF9F7FFFAF9F6FFFBF8F7FFFBF8F7FFFAF8F6FFFAF8F6FFFAF7F6FFFAF7
            F6FFFAF8F5FFA9A29EFF201613B7000000080000000100000000000000000000
            000000000000000000000100000A2A1E18D3AEA7A5FFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFACA7A4FF2016
            13B7000000080000000100000000000000000000000000000000000000000100
            000A2A1E18D3AEA7A5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4B362DFF4936
            2DFF49362DFF48352DFF48352DFF3E2D25FF201613B700000008000000010000
            0000000000000000000000000000000000000100000A2A1E18D3423129FF4C38
            30FF4B382FFF4B372FFF4A372EFF4B362DFF49362DFF49362DFF48352DFF4835
            2DFF3E2D25FF201613B700000008000000010000000000000000000000000000
            0000000000000100000A2A1E18D3423129FF4C3830FF4B382FFF4B372FFF4A37
            2EFF4B362DFF49362DFF49362DFF48352DFF48352DFF3E2D25FF201613B70000
            000800000001140E0B66645952FFFBF9F9FFFBF9F8FFFBF9F7FFFBF9F7FFFAF8
            F7FFFAF9F7FFFAF8F7FFFBF8F7FFFAF8F6FFFAF8F6FFFAF8F6FF61554FFF110C
            0962000000030000000000000000000000000000000000000000140E0B66655A
            54FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFF625751FF110C096200000003000000000000
            0000000000000000000000000000140E0B66655A54FFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFF4B382FFF4B382FFF4B372EFF4A362EFF4A362DFF4936
            2DFF372720FF110C096200000003000000000000000000000000000000000000
            0000140E0B663C2C23FF4E3A32FF4E3A32FF4D3A31FF4C3931FF4C3830FF4B38
            2FFF4B382FFF4B372EFF4A362EFF4A362DFF49362DFF372720FF110C09620000
            00030000000000000000000000000000000000000000140E0B663C2C23FF4E3A
            32FF4E3A32FF4D3A31FF4C3931FF4C3830FF4B382FFF4B382FFF4B372EFF4A36
            2EFF4A362DFF49362DFF372720FF110C096200000003261C16B9B7B0ADFFFCFA
            F9FFFCFAF9FFFBFAF8FFFCFAF8FFFBFAF8FFFCF9F8FFFBF9F8FFFBF9F8FFFBF9
            F8FFFBF9F8FFFBF8F7FFB5AEAAFF241A15BB0000000600000000000000000000
            00000000000000000000261C16B9B9B3B0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB7B2
            AFFF241A15BB000000060000000000000000000000000000000000000000261C
            16B9B9B3B0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4D3A32FF4C3A
            31FF4D3930FF4B392FFF4B382FFF4B372FFF433128FF241A15BB000000060000
            000000000000000000000000000000000000261C16B948352DFF503C33FF503C
            33FF503B33FF4F3A32FF4E3A32FF4D3A32FF4C3A31FF4D3930FF4B392FFF4B38
            2FFF4B372FFF433128FF241A15BB000000060000000000000000000000000000
            000000000000261C16B948352DFF503C33FF503C33FF503B33FF4F3A32FF4E3A
            32FF4D3A32FF4C3A31FF4D3930FF4B392FFF4B382FFF4B372FFF433128FF241A
            15BB0000000637271FECE8E5E3FFFDFCFAFFFDFBFAFFFDFBFAFFFCFAFAFFFCFA
            FAFFFCFAF9FFFCFAF9FFFBF9F8FFFBF9F8FFFBF9F9FFFCF9F8FFE6E3E0FF3022
            1CEA00000007000000000000000000000000000000000000000037271FECEAE8
            E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFFEAE8E7FF30221CEA00000007000000000000
            000000000000000000000000000037271FECEAE8E8FFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFF4F3B32FF4F3A32FF4E3A32FF4E3A31FF4D3A32FF4D3A
            30FF4A372EFF30221CEA00000007000000000000000000000000000000000000
            000037271FEC503D34FF523E36FF513D35FF503D34FF503C33FF503C34FF4F3B
            32FF4F3A32FF4E3A32FF4E3A31FF4D3A32FF4D3A30FF4A372EFF30221CEA0000
            0007000000000000000000000000000000000000000037271FEC503D34FF523E
            36FF513D35FF503D34FF503C33FF503C34FF4F3B32FF4F3A32FF4E3A32FF4E3A
            31FF4D3A32FF4D3A30FF4A372EFF30221CEA000000073D2C24FFF9F7F7FFFDFC
            FBFFFCFCFBFFFCFCFBFFFDFBFBFFFCFCFAFFFDFBFAFFFCFAFAFFFDFBFAFFFCFB
            F9FFFBFAF9FFFCFAF9FFF6F4F3FF36261EFA0000000800000000000000000000
            000000000000000000003D2C24FFFAFAFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFF513E34FF513D35FF503C34FF503C33FF4F3B33FF4F3A32FF4D3A
            32FF36261EFA0000000800000000000000000000000000000000000000003D2C
            24FFFAFAFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF513E34FF513D
            35FF503C34FF503C33FF4F3B33FF4F3A32FF4D3A32FF36261EFA000000080000
            0000000000000000000000000000000000003D2C24FF534037FF544037FF543F
            36FF533F36FF523F36FF523E35FF513E34FF513D35FF503C34FF503C33FF4F3B
            33FF4F3A32FF4D3A32FF36261EFA000000080000000000000000000000000000
            0000000000003D2C24FF534037FF544037FF543F36FF533F36FF523F36FF523E
            35FF513E34FF513D35FF503C34FF503C33FF4F3B33FF4F3A32FF4D3A32FF3626
            1EFA00000008392921EBE9E7E5FFFEFDFCFFFDFCFCFFFDFCFCFFFDFCFCFFFDFC
            FCFFFDFCFBFFFDFBFBFFFDFCFBFFFCFBFAFFFCFBFAFFFCFBFAFFE8E5E3FF3325
            1DE9000000060000000000000000000000000000000000000000392921EBEBE9
            E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF533F36FF523F36FF523E
            35FF513D35FF513D34FF503D34FF4E3931FF33251DE900000006000000000000
            0000000000000000000000000000392921EBEBE9E8FFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFF533F36FF523F36FF523E35FF513D35FF513D34FF503D
            34FF4E3931FF33251DE900000006000000000000000000000000000000000000
            0000392921EBEBE9E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF533F
            36FF523F36FF523E35FF513D35FF513D34FF503D34FF4E3931FF33251DE90000
            00060000000000000000000000000000000000000000392921EB544038FF5541
            39FF554138FF544037FF544038FF543F37FF533F36FF523F36FF523E35FF513D
            35FF513D34FF503D34FF4E3931FF33251DE9000000062D201BB8BBB4B1FFFEFE
            FEFFFEFDFCFFFEFDFDFFFEFDFCFFFEFCFCFFFDFCFCFFFDFDFCFFFDFDFBFFFDFC
            FBFFFDFCFBFFFDFBFBFFB8B2AFFF291E18B90000000500000000000000000000
            000000000000000000002D201BB8BCB6B2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFF554138FF544037FF544037FF543F36FF533F36FF533E36FF4A37
            2FFF291E18B90000000500000000000000000000000000000000000000002D20
            1BB8BCB6B2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF554138FF5440
            37FF544037FF543F36FF533F36FF533E36FF4A372FFF291E18B9000000050000
            0000000000000000000000000000000000002D201BB8BCB6B2FFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFF554138FF544037FF544037FF543F36FF533F
            36FF533E36FF4A372FFF291E18B9000000050000000000000000000000000000
            0000000000002D201BB8503C34FF58433BFF58433AFF56423AFF564239FF5641
            39FF554138FF544037FF544037FF543F36FF533F36FF533E36FF4A372FFF291E
            18B90000000518120E5F6E605AFFFEFEFEFFFEFEFEFFFEFDFDFFFEFEFDFFFEFD
            FDFFFEFDFDFFFEFDFDFFFEFCFCFFFEFDFCFFFEFCFCFFFDFDFCFF6B5E57FF150F
            0C5E00000002000000000000000000000000000000000000000018120E5F6E61
            5AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF57433AFF56423AFF5642
            39FF554138FF554038FF544037FF433128FF150F0C5E00000002000000000000
            000000000000000000000000000018120E5F6E615AFFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFFFFFFFFFF57433AFF56423AFF564239FF554138FF554038FF5440
            37FF433128FF150F0C5E00000002000000000000000000000000000000000000
            000018120E5F6E615AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5743
            3AFF56423AFF564239FF554138FF554038FF544037FF433128FF150F0C5E0000
            0002000000000000000000000000000000000000000018120E5F48352CFF5944
            3CFF58443CFF58433BFF58433AFF58433AFF57433AFF56423AFF564239FF5541
            38FF554038FF544037FF433128FF150F0C5E0000000201010006352820CEB0A8
            A4FFFFFEFEFFFEFFFEFFFEFFFEFFFFFEFEFFFEFEFEFFFEFEFEFFFFFEFDFFFEFE
            FEFFFEFDFDFFADA6A2FF2B1F1AB2000000040000000000000000000000000000
            0000000000000000000001010006352820CEB0A8A4FFFFFFFFFFFFFFFFFFFFFF
            FFFFFFFFFFFF58443CFF58443BFF58433AFF57433AFF57423AFF4D3A31FF2B1F
            1AB2000000040000000000000000000000000000000000000000000000000101
            0006352820CEB0A8A4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF58443CFF5844
            3BFF58433AFF57433AFF57423AFF4D3A31FF2B1F1AB200000004000000000000
            00000000000000000000000000000000000001010006352820CEB0A8A4FFFFFF
            FFFFFFFFFFFFFFFFFFFFFFFFFFFF58443CFF58443BFF58433AFF57433AFF5742
            3AFF4D3A31FF2B1F1AB200000004000000000000000000000000000000000000
            00000000000001010006352820CE513E35FF5B473EFF5A463DFF5A453DFF5945
            3CFF58443CFF58443BFF58433AFF57433AFF57423AFF4D3A31FF2B1F1AB20000
            000400000000000000010A07062744332BE99F9590FFFBFAF9FFFFFFFEFFFFFF
            FEFFFFFFFEFFFFFEFEFFFEFEFEFFFAF9F9FF9D938FFF3F2D25E80605041D0000
            0001000000000000000000000000000000000000000000000000000000010A07
            062744332BE99F9590FFFBFAFAFFFFFFFFFFFFFFFFFF5B463EFF5A453DFF5A44
            3DFF58443CFF4D3A31FF3D2D23E80605041D0000000100000000000000000000
            0000000000000000000000000000000000010A07062744332BE99F9590FFFBFA
            FAFFFFFFFFFFFFFFFFFF5B463EFF5A453DFF5A443DFF58443CFF4D3A31FF3D2D
            23E80605041D0000000100000000000000000000000000000000000000000000
            0000000000010A07062744332BE99F9590FFFBFAFAFFFFFFFFFFFFFFFFFF5B46
            3EFF5A453DFF5A443DFF58443CFF4D3A31FF3D2D23E80605041D000000010000
            00000000000000000000000000000000000000000000000000010A0706274030
            25E9513C34FF5B473EFF5C473FFF5C463EFF5B463EFF5A453DFF5A443DFF5844
            3CFF4D3A31FF3D2D23E80605041D000000010000000000000000000000010604
            031930231CB1675750FFC2BCB9FFEBE9E8FFFFFEFEFFEBE9E8FFC2BBB9FF6656
            4FFF2F211AB10604031A00000001000000000000000000000000000000000000
            0000000000000000000000000000000000010604031930231CB1675750FFC2BC
            B9FFEBE9E8FF5D473FFF5A453DFF544037FF49362DFF2F211AB10604031A0000
            0001000000000000000000000000000000000000000000000000000000000000
            0000000000010604031930231CB1675750FFC2BCB9FFEBE9E8FF5D473FFF5A45
            3DFF544037FF49362DFF2F211AB10604031A0000000100000000000000000000
            0000000000000000000000000000000000000000000000000001060403193023
            1CB1675750FFC2BCB9FFEBE9E8FF5D473FFF5A453DFF544037FF49362DFF2F21
            1AB10604031A0000000100000000000000000000000000000000000000000000
            00000000000000000000000000010604031930231CB14A372EFF554138FF5B46
            3DFF5D473FFF5A453DFF544037FF49362DFF2F211AB10604031A000000010000
            0000000000000000000000000000000000010000000215100C4E291F19993829
            21CB44332AF9372921CB291D1799140F0C4F0000000300000001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000010000000215100C4E291F1999382921CB44332AF9372921CB291D
            1799140F0C4F0000000300000001000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000001000000021510
            0C4E291F1999382921CB44332AF9372921CB291D1799140F0C4F000000030000
            0001000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000010000000215100C4E291F1999382921CB4433
            2AF9372921CB291D1799140F0C4F000000030000000100000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00010000000215100C4E291F1999382921CB44332AF9372921CB291D1799140F
            0C4F0000000300000001000000000000000000000000}
          ActionIndex = '5Quarters'
        end
        object dxRibbonGalleryItemIconSetsGroup4Item4: TdxRibbonGalleryGroupItem
          Glyph.SourceDPI = 96
          Glyph.Data = {
            424D361900000000000036000000280000006400000010000000010020000000
            000000000000C40E0000C40E0000000000000000000000000005000000080000
            0006000000030000000600000008000000060000000300000006000000080000
            0006000000030000000600000009000000060000000100000000000000000000
            0000000000000000000000000005000000080000000600000003000000060000
            0008000000060000000300000006000000080000000600000003000000060000
            0009000000060000000100000000000000000000000000000000000000000000
            0005000000080000000600000003000000060000000800000006000000030000
            0006000000080000000600000003000000060000000900000006000000010000
            0000000000000000000000000000000000000000000500000008000000060000
            0003000000060000000800000006000000030000000600000008000000060000
            0003000000060000000900000006000000010000000000000000000000000000
            0000000000000000000500000008000000060000000300000006000000080000
            0006000000030000000600000008000000060000000300000006000000090000
            000600000001886B63BDBD958AFF876B63BD0000000B7C5D52BDAB8074FF7C5C
            52BD0000000B7A5A52BDAB7F72FF7A5A52BD0000000C7A5A51BDAA7E71FF795B
            50BE0000000600000000000000000000000000000000000000007A4C32BDA969
            46FF7A4C32BD0000000B7C5D52BDAB8074FF7C5C52BD0000000B7A5A52BDAB7F
            72FF7A5A52BD0000000C7A5A51BDAA7E71FF795B50BE00000006000000000000
            00000000000000000000000000007A4C32BDA96946FF7A4C32BD0000000B7448
            2FBDA36442FF74482FBD0000000B7A5A52BDAB7F72FF7A5A52BD0000000C7A5A
            51BDAA7E71FF795B50BE00000006000000000000000000000000000000000000
            00007A4C32BDA96946FF7A4C32BD0000000B74482FBDA36442FF74482FBD0000
            000B73432BBDA05D3BFF73432ABD0000000C7A5A51BDAA7E71FF795B50BE0000
            000600000000000000000000000000000000000000007A4C32BDA96946FF7A4C
            32BD0000000B74482FBDA36442FF74482FBD0000000B73432BBDA05D3BFF7343
            2ABD0000000C71462FBD995738FF6E3F27BE00000006BE998CFFF4EEEBFFBE98
            8BFF0000000FBE978BFFF3ECEAFFBD968BFF00000010BC9689FFF2EBE8FFBC95
            89FF00000010BC9489FFF2EAE7FFBC9488FF0000000900000000000000000000
            00000000000000000000B27754FFFFB864FFB07551FF0000000FBE978BFFF3EC
            EAFFBD968BFF00000010BC9689FFF2EBE8FFBC9589FF00000010BC9489FFF2EA
            E7FFBC9488FF000000090000000000000000000000000000000000000000B277
            54FFFFB864FFB07551FF0000000FB57C57FFE9B16DFFB47B55FF00000010BC96
            89FFF2EBE8FFBC9589FF00000010BC9489FFF2EAE7FFBC9488FF000000090000
            000000000000000000000000000000000000B27754FFFFB864FFB07551FF0000
            000FB57C57FFE9B16DFFB47B55FF00000010B37550FFDFB279FFB27450FF0000
            0010BC9489FFF2EAE7FFBC9488FF000000090000000000000000000000000000
            000000000000B27754FFFFB864FFB07551FF0000000FB57C57FFE9B16DFFB47B
            55FF00000010B37550FFDFB279FFB27450FF00000010B47956FFE2B77FFFAC6D
            4AFF00000009C09B8FFFF5EEECFFC09A8EFF0000000FBF9A8DFFF4EEEBFFBE99
            8DFF00000010BE988CFFF3ECEAFFBE988CFF00000010BE988BFFF2EBE9FFBE96
            8AFF000000090000000000000000000000000000000000000000B57D59FFFFBC
            67FFB47A56FF0000000FBF9A8DFFF4EEEBFFBE998DFF00000010BE988CFFF3EC
            EAFFBE988CFF00000010BE988BFFF2EBE9FFBE968AFF00000009000000000000
            0000000000000000000000000000B57D59FFFFBC67FFB47A56FF0000000FB77E
            59FFEAB470FFB67D58FF00000010BE988CFFF3ECEAFFBE988CFF00000010BE98
            8BFFF2EBE9FFBE968AFF00000009000000000000000000000000000000000000
            0000B57D59FFFFBC67FFB47A56FF0000000FB77E59FFEAB470FFB67D58FF0000
            0010B57954FFE0B57CFFB47753FF00000010BE988BFFF2EBE9FFBE968AFF0000
            00090000000000000000000000000000000000000000B57D59FFFFBC67FFB47A
            56FF0000000FB77E59FFEAB470FFB67D58FF00000010B57954FFE0B57CFFB477
            53FF00000010B57B59FFE3B981FFAD704DFF00000009C29E92FFF6F0EEFFC19D
            91FF0000000EC19C90FFF4EFEDFFC09C8FFF0000000FC19B8FFFF4EEEBFFBF9A
            8EFF0000000FBF9A8EFFF3ECE9FFBF998DFF0000000800000000000000000000
            00000000000000000000B9835EFFFFBE6BFFB87F5BFF0000000EC19C90FFF4EF
            EDFFC09C8FFF0000000FC19B8FFFF4EEEBFFBF9A8EFF0000000FBF9A8EFFF3EC
            E9FFBF998DFF000000080000000000000000000000000000000000000000B983
            5EFFFFBE6BFFB87F5BFF0000000EB8815BFFECB773FFB87F5AFF0000000FC19B
            8FFFF4EEEBFFBF9A8EFF0000000FBF9A8EFFF3ECE9FFBF998DFF000000080000
            000000000000000000000000000000000000B9835EFFFFBE6BFFB87F5BFF0000
            000EB8815BFFECB773FFB87F5AFF0000000FB77C57FFE1B77EFFB77B56FF0000
            000FBF9A8EFFF3ECE9FFBF998DFF000000080000000000000000000000000000
            000000000000B9835EFFFFBE6BFFB87F5BFF0000000EB8815BFFECB773FFB87F
            5AFF0000000FB77C57FFE1B77EFFB77B56FF0000000FB8805DFFE3BB83FFAF73
            4FFF00000008C4A094FFF8F5F3FFC39F93FF0000000DC39F93FFF5F0EEFFC29E
            93FF0000000EC29E92FFF5EFECFFC19C91FF0000000EC19C90FFF4EDEBFFC19C
            90FF000000080000000000000000000000000000000000000000BD8863FFFFD0
            8CFFBA8560FF0000000DC39F93FFF5F0EEFFC29E93FF0000000EC29E92FFF5EF
            ECFFC19C91FF0000000EC19C90FFF4EDEBFFC19C90FF00000008000000000000
            0000000000000000000000000000BD8863FFFFD08CFFBA8560FF0000000DBA83
            5FFFEDB978FFBA835DFF0000000EC29E92FFF5EFECFFC19C91FF0000000EC19C
            90FFF4EDEBFFC19C90FF00000008000000000000000000000000000000000000
            0000BD8863FFFFD08CFFBA8560FF0000000DBA835FFFEDB978FFBA835DFF0000
            000EBA815BFFE3B882FFB97F5AFF0000000EC19C90FFF4EDEBFFC19C90FF0000
            00080000000000000000000000000000000000000000BD8863FFFFD08CFFBA85
            60FF0000000DBA835FFFEDB978FFBA835DFF0000000EBA815BFFE3B882FFB97F
            5AFF0000000EBA8461FFE4BC85FFB17652FF0000000893786FC1C5A297FF9178
            6FC100000009C4A195FFF6F1EFFFC4A195FF0000000DC3A095FFF5F0EEFFC39F
            94FF0000000DC39F93FFF4EEECFFC29F92FF0000000700000000000000000000
            00000000000000000000967458C1CA9C76FF967458C100000009C4A195FFF6F1
            EFFFC4A195FF0000000DC3A095FFF5F0EEFFC39F94FF0000000DC39F93FFF4EE
            ECFFC29F92FF0000000700000000000000000000000000000000000000009674
            58C1CA9C76FF967458C100000009BC8661FFEEBB7DFFBB8560FF0000000DC3A0
            95FFF5F0EEFFC39F94FF0000000DC39F93FFF4EEECFFC29F92FF000000070000
            000000000000000000000000000000000000967458C1CA9C76FF967458C10000
            0009BC8661FFEEBB7DFFBB8560FF0000000DBD8560FFE3BB85FFBC845EFF0000
            000DC39F93FFF4EEECFFC29F92FF000000070000000000000000000000000000
            000000000000967458C1CA9C76FF967458C100000009BC8661FFEEBB7DFFBB85
            60FF0000000DBD8560FFE3BB85FFBC845EFF0000000DBC8865FFE4BE87FFB37A
            55FF0000000700000003000000050000000300000006C6A499FFF6F2F1FFC6A4
            98FF0000000CC6A397FFF6F1F0FFC6A296FF0000000CC4A195FFF5F0EDFFC4A1
            95FF000000070000000000000000000000000000000000000000000000030000
            00050000000300000006C6A499FFF6F2F1FFC6A498FF0000000CC6A397FFF6F1
            F0FFC6A296FF0000000CC4A195FFF5F0EDFFC4A195FF00000007000000000000
            000000000000000000000000000000000003000000050000000300000006BE89
            64FFEFBF80FFBD8863FF0000000CC6A397FFF6F1F0FFC6A296FF0000000CC4A1
            95FFF5F0EDFFC4A195FF00000007000000000000000000000000000000000000
            000000000003000000050000000300000006BE8964FFEFBF80FFBD8863FF0000
            000CC08A64FFE5BD89FFBF8863FF0000000CC4A195FFF5F0EDFFC4A195FF0000
            0007000000000000000000000000000000000000000000000003000000050000
            000300000006BE8964FFEFBF80FFBD8863FF0000000CC08A64FFE5BD89FFBF88
            63FF0000000CBF8C6AFFE5BF8AFFB67D59FF0000000700000000000000000000
            000000000005C8A79BFFF9F6F5FFC8A69BFF0000000AC7A59AFFF7F2F0FFC7A4
            99FF0000000BC6A498FFF6F1EFFFC6A497FF0000000600000000000000000000
            0000000000000000000000000000000000000000000000000005C8A79BFFF9F6
            F5FFC8A69BFF0000000AC7A59AFFF7F2F0FFC7A499FF0000000BC6A498FFF6F1
            EFFFC6A497FF0000000600000000000000000000000000000000000000000000
            0000000000000000000000000005BF8C67FFF4CF9EFFBF8B65FF0000000AC7A5
            9AFFF7F2F0FFC7A499FF0000000BC6A498FFF6F1EFFFC6A497FF000000060000
            0000000000000000000000000000000000000000000000000000000000000000
            0005BF8C67FFF4CF9EFFBF8B65FF0000000AC38E69FFE5C08CFFC28D67FF0000
            000BC6A498FFF6F1EFFFC6A497FF000000060000000000000000000000000000
            00000000000000000000000000000000000000000005BF8C67FFF4CF9EFFBF8B
            65FF0000000AC38E69FFE5C08CFFC28D67FF0000000BC2906EFFE7C18DFFB881
            5CFF0000000600000000000000000000000000000003977D75C0CAA99DFF967D
            75C000000008C9A89DFFF8F4F2FFC9A79CFF0000000AC9A79CFFF7F3F1FFC8A6
            9AFF000000050000000000000000000000000000000000000000000000000000
            00000000000000000003977D75C0CAA99DFF967D75C000000008C9A89DFFF8F4
            F2FFC9A79CFF0000000AC9A79CFFF7F3F1FFC8A69AFF00000005000000000000
            0000000000000000000000000000000000000000000000000000000000038E69
            4EC0C18D69FF8E694DC000000008C9A89DFFF8F4F2FFC9A79CFF0000000AC9A7
            9CFFF7F3F1FFC8A69AFF00000005000000000000000000000000000000000000
            0000000000000000000000000000000000038E694EC0C18D69FF8E694DC00000
            0008C5926DFFE6C18FFFC4916CFF0000000AC9A79CFFF7F3F1FFC8A69AFF0000
            0005000000000000000000000000000000000000000000000000000000000000
            0000000000038E694EC0C18D69FF8E694DC000000008C5926DFFE6C18FFFC491
            6CFF0000000AC49571FFE7C290FFBB8560FF0000000500000000000000000000
            00000000000100000002000000040000000300000005CBAA9FFFF8F4F4FFCAA9
            9FFF00000009CAA99EFFF7F4F2FFCAA89DFF0000000500000000000000000000
            0000000000000000000000000000000000000000000000000001000000020000
            00040000000300000005CBAA9FFFF8F4F4FFCAA99FFF00000009CAA99EFFF7F4
            F2FFCAA89DFF0000000500000000000000000000000000000000000000000000
            000000000000000000000000000100000002000000040000000300000005CBAA
            9FFFF8F4F4FFCAA99FFF00000009CAA99EFFF7F4F2FFCAA89DFF000000050000
            0000000000000000000000000000000000000000000000000000000000000000
            000100000002000000040000000300000005C79871FFE7C492FFC7976FFF0000
            0009CAA99EFFF7F4F2FFCAA89DFF000000050000000000000000000000000000
            0000000000000000000000000000000000000000000100000002000000040000
            000300000005C79871FFE7C492FFC7976FFF00000009C69976FFE8C392FFBD89
            63FF000000050000000000000000000000000000000000000000000000000000
            000000000004CDADA2FFFBF8F8FFCCACA1FF00000008CCACA0FFF8F4F3FFCCAC
            A0FF000000040000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000004CDADA2FFFBF8
            F8FFCCACA1FF00000008CCACA0FFF8F4F3FFCCACA0FF00000004000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000004CDADA2FFFBF8F8FFCCACA1FF00000008CCAC
            A0FFF8F4F3FFCCACA0FF00000004000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0004C99B74FFEFD4ABFFC99B74FF00000008CCACA0FFF8F4F3FFCCACA0FF0000
            0004000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000004C99B74FFEFD4ABFFC99B
            74FF00000008C99D7AFFE9C494FFBF8C67FF0000000400000000000000000000
            000000000000000000000000000000000000000000029A8279BFCFB0A5FF9982
            79BF00000006CEAEA3FFF9F6F5FFCDADA3FF0000000400000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000029A8279BFCFB0A5FF998279BF00000006CEAEA3FFF9F6
            F5FFCDADA3FF0000000400000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000029A82
            79BFCFB0A5FF998279BF00000006CEAEA3FFF9F6F5FFCDADA3FF000000040000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002977658BFCC9F77FF977558BF0000
            0006CEAEA3FFF9F6F5FFCDADA3FF000000040000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002977658BFCC9F77FF977558BF00000006CBA17DFFE9C696FFC18F
            6AFF000000040000000000000000000000000000000000000000000000000000
            00000000000000000002000000030000000200000004CFB0A5FFFAF7F6FFCFB0
            A5FF000000030000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000020000
            00030000000200000004CFB0A5FFFAF7F6FFCFB0A5FF00000003000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000002000000030000000200000004CFB0
            A5FFFAF7F6FFCFB0A5FF00000003000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000002000000030000000200000004CFB0A5FFFAF7F6FFCFB0A5FF0000
            0003000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000002000000030000
            000200000004CEA481FFE9C797FFC3936DFF0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000003D1B3A8FFFCFAF9FFD1B3A8FF0000000300000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000003D1B3A8FFFCFA
            F9FFD1B3A8FF0000000300000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000003D1B3A8FFFCFAF9FFD1B3A8FF000000030000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0003D1B3A8FFFCFAF9FFD1B3A8FF000000030000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000000000000000000000000003D0A785FFEFD5B0FFC596
            70FF000000030000000000000000000000000000000000000000000000000000
            000000000000000000000000000000000000000000019D877FBFD3B5ABFF9D85
            7EBF000000020000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000019D877FBFD3B5ABFF9D857EBF00000002000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000019D87
            7FBFD3B5ABFF9D857EBF00000002000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000019D877FBFD3B5ABFF9D857EBF0000
            0002000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000019C7E64BFD1AA88FF9A7C64BF00000002}
          ActionIndex = '5Rating'
        end
      end
    end
    object dxBarLargeButtonNewRule: TdxBarLargeButton
      Action = dxSpreadSheetConditionalFormattingNewRule
      Category = 19
      LargeImageIndex = 122
      SyncImageIndex = False
      ImageIndex = 122
    end
    object dxBarSubItem15: TdxBarSubItem
      Caption = 'Clear Rules'
      Category = 19
      Visible = ivAlways
      ImageIndex = 59
      LargeImageIndex = 59
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonClearRulesFromSelectedCells'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonClearRulesFromEntireSheet'
        end>
    end
    object dxBarLargeButtonClearRulesFromSelectedCells: TdxBarLargeButton
      Action = dxSpreadSheetConditionalFormattingClearRulesFromSelectedCells
      Category = 19
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonClearRulesFromEntireSheet: TdxBarLargeButton
      Action = dxSpreadSheetConditionalFormattingClearRulesFromEntireSheet
      Category = 19
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonManageRules: TdxBarLargeButton
      Action = dxSpreadSheetShowConditionalFormattingRulesManager
      Category = 19
      LargeImageIndex = 527
      SyncImageIndex = False
      ImageIndex = 527
    end
    object dxBarButtonSingleSheet: TdxBarButton
      Action = dxSpreadSheetReportDesignerSingleSheetReportMode
      Category = 20
      ButtonStyle = bsChecked
      ImageIndex = 234
      LargeImageIndex = 234
    end
    object dxBarButtonMultipleSheets: TdxBarButton
      Action = dxSpreadSheetReportDesignerMultipleSheetsReportMode
      Category = 20
      ButtonStyle = bsChecked
      ImageIndex = 234
      LargeImageIndex = 234
    end
    object dxBarButtonMultipleDocuments: TdxBarButton
      Action = dxSpreadSheetReportDesignerMultipleDocumentsReportMode
      Category = 20
      ButtonStyle = bsChecked
      ImageIndex = 292
      LargeImageIndex = 292
    end
    object dxBarSubItem16: TdxBarSubItem
      Caption = 'Document Orientation'
      Category = 20
      Visible = ivAlways
      ImageIndex = 298
      LargeImageIndex = 298
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonHorizontal'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonVertical'
        end>
    end
    object dxBarLargeButtonHorizontal: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerHorizontalOrientation
      Category = 20
      ButtonStyle = bsChecked
      LargeImageIndex = 18
      SyncImageIndex = False
      ImageIndex = 18
    end
    object dxBarLargeButtonVertical: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerVerticalOrientation
      Category = 20
      ButtonStyle = bsChecked
      LargeImageIndex = 281
      SyncImageIndex = False
      ImageIndex = 281
    end
    object dxBarButtonHeader: TdxBarButton
      Action = dxSpreadSheetReportDesignerHeaderSection
      Category = 21
      ButtonStyle = bsChecked
      ImageIndex = 234
      LargeImageIndex = 234
    end
    object dxBarButtonFooter: TdxBarButton
      Action = dxSpreadSheetReportDesignerFooterSection
      Category = 21
      ButtonStyle = bsChecked
      ImageIndex = 234
      LargeImageIndex = 234
    end
    object dxBarLargeButtonDetail: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerDetailSection
      Category = 21
      ButtonStyle = bsChecked
      LargeImageIndex = 234
      SyncImageIndex = False
      ImageIndex = 234
    end
    object dxBarSubItem17: TdxBarSubItem
      Caption = 'Master-Detail'
      Category = 21
      Visible = ivAlways
      ImageIndex = 444
      LargeImageIndex = 444
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDetailLevel'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDataMember'
        end>
    end
    object dxBarLargeButtonDetailLevel: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerDetailLevel
      Category = 21
      ButtonStyle = bsChecked
      LargeImageIndex = 444
      SyncImageIndex = False
      ImageIndex = 444
    end
    object dxBarLargeButtonDataMember: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerDataMember
      Category = 21
      ButtonStyle = bsChecked
      LargeImageIndex = 42
      SyncImageIndex = False
      ImageIndex = 42
    end
    object dxBarLargeButtonReset: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerResetSection
      Category = 21
      ButtonStyle = bsChecked
      LargeImageIndex = 73
      SyncImageIndex = False
      ImageIndex = 73
    end
    object dxBarLargeButtonSortFields: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerSortFields
      Category = 22
      ButtonStyle = bsChecked
      LargeImageIndex = 130
      SyncImageIndex = False
      ImageIndex = 130
    end
    object dxBarButtonGroupHeader: TdxBarButton
      Action = dxSpreadSheetReportDesignerGroupHeaderSection
      Category = 22
      ButtonStyle = bsChecked
      ImageIndex = 284
      LargeImageIndex = 284
    end
    object dxBarButtonGroupFooter: TdxBarButton
      Action = dxSpreadSheetReportDesignerGroupFooterSection
      Category = 22
      ButtonStyle = bsChecked
      ImageIndex = 284
      LargeImageIndex = 284
    end
    object dxBarLargeButtonEditFilter: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerEditFilter
      Category = 23
      ButtonStyle = bsChecked
      LargeImageIndex = 80
      SyncImageIndex = False
      ImageIndex = 80
    end
    object dxBarLargeButtonResetFilter: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerResetFilter
      Category = 23
      ButtonStyle = bsChecked
      LargeImageIndex = 57
      SyncImageIndex = False
      ImageIndex = 57
    end
    object dxBarLargeButtonDesignView: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerDesignView
      Category = 24
      ButtonStyle = bsChecked
      LargeImageIndex = 511
      SyncImageIndex = False
      ImageIndex = 511
    end
    object dxBarLargeButtonReportPreview: TdxBarLargeButton
      Action = dxSpreadSheetReportDesignerReportPreview
      Category = 24
      ButtonStyle = bsChecked
      LargeImageIndex = 185
      SyncImageIndex = False
      ImageIndex = 185
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 256
    Top = 200
    object dxSpreadSheetNewDocument: TdxSpreadSheetNewDocument
      Category = 'DevExpress ExpressSpreadSheet.File.Common'
      ImageIndex = 3
    end
    object dxSpreadSheetOpenDocument: TdxFileOpen
      Dialog.DefaultExt = '*.xlsx'
      Dialog.Filter = 'Excel|*.xlsx|Tutti|*.*'
      ImageIndex = 36
      BeforeExecute = dxSpreadSheetOpenDocumentBeforeExecute
      OnAccept = dxSpreadSheetOpenDocumentAccept
    end
    object dxSpreadSheetSaveDocumentAs: TdxFileSaveAs
      Dialog.DefaultExt = '*.xlsx'
      Dialog.Filter = 'Excel|*.xlsx|Tutti|*.*'
      Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
      ImageIndex = 92
      BeforeExecute = dxSpreadSheetSaveDocumentAsBeforeExecute
      OnAccept = dxSpreadSheetSaveDocumentAsAccept
    end
    object dxSpreadSheetShowPrintForm: TdxSpreadSheetShowPrintForm
      Category = 'DevExpress ExpressSpreadSheet.File.Print'
      ImageIndex = 208
    end
    object dxSpreadSheetShowPrintPreviewForm: TdxSpreadSheetShowPrintPreviewForm
      Category = 'DevExpress ExpressSpreadSheet.File.Print'
      ImageIndex = 169
    end
    object dxSpreadSheetShowPageSetupForm: TdxSpreadSheetShowPageSetupForm
      Category = 'DevExpress ExpressSpreadSheet.File.Print'
      ImageIndex = 301
    end
    object dxSpreadSheetPasteSelection: TdxSpreadSheetPasteSelection
      Category = 'DevExpress ExpressSpreadSheet.Home.Clipboard'
      ImageIndex = 85
    end
    object dxSpreadSheetCutSelection: TdxSpreadSheetCutSelection
      Category = 'DevExpress ExpressSpreadSheet.Home.Clipboard'
      ImageIndex = 65
    end
    object dxSpreadSheetCopySelection: TdxSpreadSheetCopySelection
      Category = 'DevExpress ExpressSpreadSheet.Home.Clipboard'
      ImageIndex = 64
    end
    object dxSpreadSheetChangeFontName: TdxSpreadSheetChangeFontName
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
    end
    object dxSpreadSheetChangeFontSize: TdxSpreadSheetChangeFontSize
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
    end
    object dxSpreadSheetIncreaseFontSize: TdxSpreadSheetIncreaseFontSize
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 332
    end
    object dxSpreadSheetDecreaseFontSize: TdxSpreadSheetDecreaseFontSize
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 518
    end
    object dxSpreadSheetToggleFontBold: TdxSpreadSheetToggleFontBold
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 324
    end
    object dxSpreadSheetToggleFontItalic: TdxSpreadSheetToggleFontItalic
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 339
    end
    object dxSpreadSheetToggleFontUnderline: TdxSpreadSheetToggleFontUnderline
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 358
    end
    object dxSpreadSheetToggleFontStrikeout: TdxSpreadSheetToggleFontStrikeout
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 347
    end
    object dxSpreadSheetBordersBottom: TdxSpreadSheetBordersBottom
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 250
    end
    object dxSpreadSheetBordersTop: TdxSpreadSheetBordersTop
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 261
    end
    object dxSpreadSheetBordersLeft: TdxSpreadSheetBordersLeft
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 255
    end
    object dxSpreadSheetBordersRight: TdxSpreadSheetBordersRight
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 257
    end
    object dxSpreadSheetBordersNone: TdxSpreadSheetBordersNone
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 256
    end
    object dxSpreadSheetBordersAll: TdxSpreadSheetBordersAll
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 248
    end
    object dxSpreadSheetBordersOutside: TdxSpreadSheetBordersOutside
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 259
    end
    object dxSpreadSheetBordersOutsideThick: TdxSpreadSheetBordersOutsideThick
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 260
    end
    object dxSpreadSheetBordersBottomDouble: TdxSpreadSheetBordersBottomDouble
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 251
    end
    object dxSpreadSheetBordersBottomThick: TdxSpreadSheetBordersBottomThick
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 252
    end
    object dxSpreadSheetBordersTopAndBottom: TdxSpreadSheetBordersTopAndBottom
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 262
    end
    object dxSpreadSheetBordersTopAndBottomThick: TdxSpreadSheetBordersTopAndBottomThick
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 264
    end
    object dxSpreadSheetBordersTopAndBottomDouble: TdxSpreadSheetBordersTopAndBottomDouble
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 263
    end
    object dxSpreadSheetBordersMore: TdxSpreadSheetBordersMore
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
    end
    object dxSpreadSheetChangeFillColor: TdxSpreadSheetChangeFillColor
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 426
    end
    object dxSpreadSheetChangeFontColor: TdxSpreadSheetChangeFontColor
      Category = 'DevExpress ExpressSpreadSheet.Home.Font'
      ImageIndex = 330
    end
    object dxSpreadSheetAlignVerticalTop: TdxSpreadSheetAlignVerticalTop
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 320
    end
    object dxSpreadSheetAlignVerticalCenter: TdxSpreadSheetAlignVerticalCenter
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 316
    end
    object dxSpreadSheetAlignVerticalBottom: TdxSpreadSheetAlignVerticalBottom
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 309
    end
    object dxSpreadSheetAlignHorizontalLeft: TdxSpreadSheetAlignHorizontalLeft
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 315
    end
    object dxSpreadSheetAlignHorizontalCenter: TdxSpreadSheetAlignHorizontalCenter
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 312
    end
    object dxSpreadSheetAlignHorizontalRight: TdxSpreadSheetAlignHorizontalRight
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 319
    end
    object dxSpreadSheetTextIndentDecrease: TdxSpreadSheetTextIndentDecrease
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 334
    end
    object dxSpreadSheetTextIndentIncrease: TdxSpreadSheetTextIndentIncrease
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 336
    end
    object dxSpreadSheetTextWrap: TdxSpreadSheetTextWrap
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 183
    end
    object dxSpreadSheetMergeCellsAndCenter: TdxSpreadSheetMergeCellsAndCenter
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 276
    end
    object dxSpreadSheetMergeCellsAcross: TdxSpreadSheetMergeCellsAcross
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 274
    end
    object dxSpreadSheetMergeCells: TdxSpreadSheetMergeCells
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 275
    end
    object dxSpreadSheetUnmergeCells: TdxSpreadSheetUnmergeCells
      Category = 'DevExpress ExpressSpreadSheet.Home.Alignment'
      ImageIndex = 288
    end
    object dxSpreadSheetInsertRows: TdxSpreadSheetInsertRows
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
      ImageIndex = 108
    end
    object dxSpreadSheetInsertColumns: TdxSpreadSheetInsertColumns
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
      ImageIndex = 100
    end
    object dxSpreadSheetInsertSheet: TdxSpreadSheetInsertSheet
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
      ImageIndex = 50
    end
    object dxSpreadSheetDeleteRows: TdxSpreadSheetDeleteRows
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
      ImageIndex = 72
    end
    object dxSpreadSheetDeleteColumns: TdxSpreadSheetDeleteColumns
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
      ImageIndex = 71
    end
    object dxSpreadSheetDeleteSheet: TdxSpreadSheetDeleteSheet
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
      ImageIndex = 66
    end
    object dxSpreadSheetAutoFitRowHeight: TdxSpreadSheetAutoFitRowHeight
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetAutoFitColumnWidth: TdxSpreadSheetAutoFitColumnWidth
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetHideRows: TdxSpreadSheetHideRows
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetHideColumns: TdxSpreadSheetHideColumns
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetHideSheet: TdxSpreadSheetHideSheet
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetUnhideRows: TdxSpreadSheetUnhideRows
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetUnhideColumns: TdxSpreadSheetUnhideColumns
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetUnhideSheet: TdxSpreadSheetUnhideSheet
      Category = 'DevExpress ExpressSpreadSheet.Home.Cells'
    end
    object dxSpreadSheetClearAll: TdxSpreadSheetClearAll
      Category = 'DevExpress ExpressSpreadSheet.Home.Editing'
      ImageIndex = 56
    end
    object dxSpreadSheetClearFormats: TdxSpreadSheetClearFormats
      Category = 'DevExpress ExpressSpreadSheet.Home.Editing'
      ImageIndex = 58
    end
    object dxSpreadSheetClearContents: TdxSpreadSheetClearContents
      Category = 'DevExpress ExpressSpreadSheet.Home.Editing'
    end
    object dxSpreadSheetUndo: TdxSpreadSheetUndo
      Category = 'DevExpress ExpressSpreadSheet.Home.Editing'
      ImageIndex = 96
    end
    object dxSpreadSheetRedo: TdxSpreadSheetRedo
      Category = 'DevExpress ExpressSpreadSheet.Home.Editing'
      ImageIndex = 87
    end
    object dxSpreadSheetFindAndReplace: TdxSpreadSheetFindAndReplace
      Category = 'DevExpress ExpressSpreadSheet.Home.Editing'
      ImageIndex = 189
    end
    object dxSpreadSheetInsertPicture: TdxSpreadSheetInsertPicture
      Category = 'DevExpress ExpressSpreadSheet.Insert.Illustrations'
      ImageIndex = 419
    end
    object dxSpreadSheetShowHyperlinkEditor: TdxSpreadSheetShowHyperlinkEditor
      Category = 'DevExpress ExpressSpreadSheet.Insert.Links'
      ImageIndex = 525
    end
    object dxSpreadSheetPageMarginsGallery: TdxSpreadSheetPageMarginsGallery
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
      ImageIndex = 296
      GalleryGroup = dxRibbonGalleryItemMarginsGroup1
    end
    object dxSpreadSheetMorePageMargins: TdxSpreadSheetMorePageMargins
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
    end
    object dxSpreadSheetPageOrientationGallery: TdxSpreadSheetPageOrientationGallery
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
      ImageIndex = 297
      GalleryGroup = dxRibbonGalleryItemOrientationGroup1
    end
    object dxSpreadSheetPaperSizeGallery: TdxSpreadSheetPaperSizeGallery
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
      ImageIndex = 295
      GalleryGroup = dxRibbonGalleryItemSizeGroup1
    end
    object dxSpreadSheetMorePaperSizes: TdxSpreadSheetMorePaperSizes
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
    end
    object dxSpreadSheetSetPrintArea: TdxSpreadSheetSetPrintArea
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
      ImageIndex = 297
    end
    object dxSpreadSheetClearPrintArea: TdxSpreadSheetClearPrintArea
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
    end
    object dxSpreadSheetInsertPageBreak: TdxSpreadSheetInsertPageBreak
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
    end
    object dxSpreadSheetRemovePageBreak: TdxSpreadSheetRemovePageBreak
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
    end
    object dxSpreadSheetResetAllPageBreaks: TdxSpreadSheetResetAllPageBreaks
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
    end
    object dxSpreadSheetPrintTitles: TdxSpreadSheetPrintTitles
      Category = 'DevExpress ExpressSpreadSheet.Page Layout.Page Setup'
      ImageIndex = 296
    end
    object dxSpreadSheetAutoSumGallery: TdxSpreadSheetAutoSumGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 297
      GalleryGroup = dxRibbonGalleryItemAutoSumGroup1
    end
    object dxSpreadSheetFinancialFormulasGallery: TdxSpreadSheetFinancialFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 303
      GalleryGroup = dxRibbonGalleryItemFinancialGroup1
    end
    object dxSpreadSheetLogicalFormulasGallery: TdxSpreadSheetLogicalFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 303
      GalleryGroup = dxRibbonGalleryItemLogicalGroup1
    end
    object dxSpreadSheetTextFormulasGallery: TdxSpreadSheetTextFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 414
      GalleryGroup = dxRibbonGalleryItemTextGroup1
    end
    object dxSpreadSheetDateAndTimeFormulasGallery: TdxSpreadSheetDateAndTimeFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 414
      GalleryGroup = dxRibbonGalleryItemDateTimeGroup1
    end
    object dxSpreadSheetLookupAndReferenceFormulasGallery: TdxSpreadSheetLookupAndReferenceFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 304
      GalleryGroup = dxRibbonGalleryItemLookupReferenceGroup1
    end
    object dxSpreadSheetMathAndTrigFormulasGallery: TdxSpreadSheetMathAndTrigFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 305
      GalleryGroup = dxRibbonGalleryItemMathTrigGroup1
    end
    object dxSpreadSheetStatisticalFormulasGallery: TdxSpreadSheetStatisticalFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 414
      GalleryGroup = dxRibbonGalleryItemStatisticalGroup1
    end
    object dxSpreadSheetInformationFormulasGallery: TdxSpreadSheetInformationFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 302
      GalleryGroup = dxRibbonGalleryItemInformationGroup1
    end
    object dxSpreadSheetCompatibilityFormulasGallery: TdxSpreadSheetCompatibilityFormulasGallery
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Function Library'
      ImageIndex = 303
      GalleryGroup = dxRibbonGalleryItemCompatibilityGroup1
    end
    object dxSpreadSheetShowDefinedNameManager: TdxSpreadSheetShowDefinedNameManager
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Defined Names'
      ImageIndex = 303
    end
    object dxSpreadSheetCreateDefinedName: TdxSpreadSheetCreateDefinedName
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Defined Names'
      ImageIndex = 303
    end
    object dxSpreadSheetUseDefinedNameInFormula: TdxSpreadSheetUseDefinedNameInFormula
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Defined Names'
      ImageIndex = 414
      GalleryGroup = dxRibbonGalleryItemUseinFormulaGroup1
    end
    object dxSpreadSheetCreateDefinedNamesFromSelection: TdxSpreadSheetCreateDefinedNamesFromSelection
      Category = 'DevExpress ExpressSpreadSheet.Formulas.Defined Names'
      ImageIndex = 414
    end
    object dxSpreadSheetSortAscending: TdxSpreadSheetSortAscending
      Category = 'DevExpress ExpressSpreadSheet.Data.Sort Filter'
      ImageIndex = 304
    end
    object dxSpreadSheetSortDescending: TdxSpreadSheetSortDescending
      Category = 'DevExpress ExpressSpreadSheet.Data.Sort Filter'
      ImageIndex = 305
    end
    object dxSpreadSheetGroupColumns: TdxSpreadSheetGroupColumns
      Category = 'DevExpress ExpressSpreadSheet.Data.Grouping'
      ImageIndex = 414
    end
    object dxSpreadSheetGroupRows: TdxSpreadSheetGroupRows
      Category = 'DevExpress ExpressSpreadSheet.Data.Grouping'
      ImageIndex = 302
    end
    object dxSpreadSheetUngroupColumns: TdxSpreadSheetUngroupColumns
      Category = 'DevExpress ExpressSpreadSheet.Data.Grouping'
      ImageIndex = 303
    end
    object dxSpreadSheetUngroupRows: TdxSpreadSheetUngroupRows
      Category = 'DevExpress ExpressSpreadSheet.Data.Grouping'
      ImageIndex = 303
    end
    object dxSpreadSheetNewComment: TdxSpreadSheetNewComment
      Category = 'DevExpress ExpressSpreadSheet.Review.Comments'
      ImageIndex = 414
    end
    object dxSpreadSheetEditComment: TdxSpreadSheetEditComment
      Category = 'DevExpress ExpressSpreadSheet.Review.Comments'
      ImageIndex = 414
    end
    object dxSpreadSheetDeleteComments: TdxSpreadSheetDeleteComments
      Category = 'DevExpress ExpressSpreadSheet.Review.Comments'
      ImageIndex = 306
    end
    object dxSpreadSheetPreviousComment: TdxSpreadSheetPreviousComment
      Category = 'DevExpress ExpressSpreadSheet.Review.Comments'
      ImageIndex = 207
    end
    object dxSpreadSheetNextComment: TdxSpreadSheetNextComment
      Category = 'DevExpress ExpressSpreadSheet.Review.Comments'
      ImageIndex = 207
    end
    object dxSpreadSheetShowHideComments: TdxSpreadSheetShowHideComments
      Category = 'DevExpress ExpressSpreadSheet.Review.Comments'
      ImageIndex = 105
    end
    object dxSpreadSheetProtectSheet: TdxSpreadSheetProtectSheet
      Category = 'DevExpress ExpressSpreadSheet.Review.Changes'
      ImageIndex = 291
    end
    object dxSpreadSheetProtectWorkbook: TdxSpreadSheetProtectWorkbook
      Category = 'DevExpress ExpressSpreadSheet.Review.Changes'
      ImageIndex = 247
    end
    object dxSpreadSheetZoomOut: TdxSpreadSheetZoomOut
      Category = 'DevExpress ExpressSpreadSheet.View.Zoom'
      ImageIndex = 403
    end
    object dxSpreadSheetZoomIn: TdxSpreadSheetZoomIn
      Category = 'DevExpress ExpressSpreadSheet.View.Zoom'
      ImageIndex = 405
    end
    object dxSpreadSheetZoomDefault: TdxSpreadSheetZoomDefault
      Category = 'DevExpress ExpressSpreadSheet.View.Zoom'
      ImageIndex = 458
    end
    object dxSpreadSheetFreezePanes: TdxSpreadSheetFreezePanes
      Category = 'DevExpress ExpressSpreadSheet.View.Freeze Panes'
      ImageIndex = 406
    end
    object dxSpreadSheetUnfreezePanes: TdxSpreadSheetUnfreezePanes
      Category = 'DevExpress ExpressSpreadSheet.View.Freeze Panes'
      ImageIndex = 544
    end
    object dxSpreadSheetFreezeTopRow: TdxSpreadSheetFreezeTopRow
      Category = 'DevExpress ExpressSpreadSheet.View.Freeze Panes'
      ImageIndex = 408
    end
    object dxSpreadSheetFreezeFirstColumn: TdxSpreadSheetFreezeFirstColumn
      Category = 'DevExpress ExpressSpreadSheet.View.Freeze Panes'
      ImageIndex = 410
    end
    object dxSpreadSheetConditionalFormattingTopBottomRulesGallery: TdxSpreadSheetConditionalFormattingTopBottomRulesGallery
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
      ImageIndex = 399
      GalleryGroup = dxRibbonGalleryItemTopBottomRulesGroup1
    end
    object dxSpreadSheetConditionalFormattingMoreRules: TdxSpreadSheetConditionalFormattingMoreRules
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
    end
    object dxSpreadSheetConditionalFormattingDataBarsGallery: TdxSpreadSheetConditionalFormattingDataBarsGallery
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
      ImageIndex = 494
      GalleryGroupGradientFill = dxRibbonGalleryItemDataBarsGroup1
      GalleryGroupSolidFill = dxRibbonGalleryItemDataBarsGroup2
    end
    object dxSpreadSheetConditionalFormattingColorScalesGallery: TdxSpreadSheetConditionalFormattingColorScalesGallery
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
      ImageIndex = 495
    end
    object dxSpreadSheetConditionalFormattingIconSetsGallery: TdxSpreadSheetConditionalFormattingIconSetsGallery
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
      ImageIndex = 460
      GalleryGroupDirectional = dxRibbonGalleryItemIconSetsGroup1
      GalleryGroupIndicators = dxRibbonGalleryItemIconSetsGroup2
      GalleryGroupRatings = dxRibbonGalleryItemIconSetsGroup4
      GalleryGroupShapes = dxRibbonGalleryItemIconSetsGroup3
    end
    object dxSpreadSheetConditionalFormattingNewRule: TdxSpreadSheetConditionalFormattingNewRule
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
      ImageIndex = 459
    end
    object dxSpreadSheetConditionalFormattingClearRulesFromSelectedCells: TdxSpreadSheetConditionalFormattingClearRulesFromSelectedCells
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
    end
    object dxSpreadSheetConditionalFormattingClearRulesFromEntireSheet: TdxSpreadSheetConditionalFormattingClearRulesFromEntireSheet
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
    end
    object dxSpreadSheetShowConditionalFormattingRulesManager: TdxSpreadSheetShowConditionalFormattingRulesManager
      Category = 'DevExpress ExpressSpreadSheet.Home.Conditional Formatting'
      ImageIndex = 272
    end
    object dxSpreadSheetReportDesignerSingleSheetReportMode: TdxSpreadSheetReportDesignerSingleSheetReportMode
      Category = 'DevExpress ExpressSpreadSheet.Report.Mode'
      ImageIndex = 272
    end
    object dxSpreadSheetReportDesignerMultipleSheetsReportMode: TdxSpreadSheetReportDesignerMultipleSheetsReportMode
      Category = 'DevExpress ExpressSpreadSheet.Report.Mode'
      ImageIndex = 174
    end
    object dxSpreadSheetReportDesignerMultipleDocumentsReportMode: TdxSpreadSheetReportDesignerMultipleDocumentsReportMode
      Category = 'DevExpress ExpressSpreadSheet.Report.Mode'
      ImageIndex = 273
    end
    object dxSpreadSheetReportDesignerHorizontalOrientation: TdxSpreadSheetReportDesignerHorizontalOrientation
      Category = 'DevExpress ExpressSpreadSheet.Report.Mode'
      ImageIndex = 378
    end
    object dxSpreadSheetReportDesignerVerticalOrientation: TdxSpreadSheetReportDesignerVerticalOrientation
      Category = 'DevExpress ExpressSpreadSheet.Report.Mode'
      ImageIndex = 394
    end
    object dxSpreadSheetReportDesignerHeaderSection: TdxSpreadSheetReportDesignerHeaderSection
      Category = 'DevExpress ExpressSpreadSheet.Report.Template Sections'
      ImageIndex = 214
    end
    object dxSpreadSheetReportDesignerFooterSection: TdxSpreadSheetReportDesignerFooterSection
      Category = 'DevExpress ExpressSpreadSheet.Report.Template Sections'
      ImageIndex = 227
    end
    object dxSpreadSheetReportDesignerDetailSection: TdxSpreadSheetReportDesignerDetailSection
      Category = 'DevExpress ExpressSpreadSheet.Report.Template Sections'
      ImageIndex = 231
    end
    object dxSpreadSheetReportDesignerDetailLevel: TdxSpreadSheetReportDesignerDetailLevel
      Category = 'DevExpress ExpressSpreadSheet.Report.Template Sections'
      ImageIndex = 228
    end
    object dxSpreadSheetReportDesignerDataMember: TdxSpreadSheetReportDesignerDataMember
      Category = 'DevExpress ExpressSpreadSheet.Report.Template Sections'
      ImageIndex = 230
    end
    object dxSpreadSheetReportDesignerResetSection: TdxSpreadSheetReportDesignerResetSection
      Category = 'DevExpress ExpressSpreadSheet.Report.Template Sections'
      ImageIndex = 215
    end
    object dxSpreadSheetReportDesignerSortFields: TdxSpreadSheetReportDesignerSortFields
      Category = 'DevExpress ExpressSpreadSheet.Report.Sort & Group'
      ImageIndex = 233
    end
    object dxSpreadSheetReportDesignerGroupHeaderSection: TdxSpreadSheetReportDesignerGroupHeaderSection
      Category = 'DevExpress ExpressSpreadSheet.Report.Sort & Group'
      ImageIndex = 245
    end
    object dxSpreadSheetReportDesignerGroupFooterSection: TdxSpreadSheetReportDesignerGroupFooterSection
      Category = 'DevExpress ExpressSpreadSheet.Report.Sort & Group'
      ImageIndex = 246
    end
    object dxSpreadSheetReportDesignerEditFilter: TdxSpreadSheetReportDesignerEditFilter
      Category = 'DevExpress ExpressSpreadSheet.Report.Filter'
      ImageIndex = 239
    end
    object dxSpreadSheetReportDesignerResetFilter: TdxSpreadSheetReportDesignerResetFilter
      Category = 'DevExpress ExpressSpreadSheet.Report.Filter'
      ImageIndex = 242
    end
    object dxSpreadSheetReportDesignerDesignView: TdxSpreadSheetReportDesignerDesignView
      Category = 'DevExpress ExpressSpreadSheet.Report.Design'
      ImageIndex = 214
    end
    object dxSpreadSheetReportDesignerReportPreview: TdxSpreadSheetReportDesignerReportPreview
      Category = 'DevExpress ExpressSpreadSheet.Report.Design'
      ImageIndex = 227
    end
    object Chiudi: TAction
      Caption = 'Chiudi'
      ImageIndex = 60
      OnExecute = ChiudiExecute
    end
    object MostraFormule: TAction
      Caption = 'Mostra Formule'
      ImageIndex = 449
      OnExecute = MostraFormuleExecute
    end
    object Elabora: TAction
      Caption = 'Elabora'
      ImageIndex = 502
      ShortCut = 120
      OnExecute = ElaboraExecute
    end
    object actSalvaConNome: TAction
      Caption = 'Salva con nome'
      ImageIndex = 226
      OnExecute = actSalvaConNomeExecute
    end
    object actSalva: TAction
      Caption = 'Salva'
      ImageIndex = 92
      OnExecute = actSalvaExecute
      OnUpdate = actSalvaUpdate
    end
    object actShellExecute: TAction
      Caption = 'Editor sistema'
      ImageIndex = 36
      OnExecute = actShellExecuteExecute
    end
  end
  object DataSource: TDataSource
    Left = 256
    Top = 488
  end
  object dxSaveFileDialogXlsx: TdxSaveFileDialog
    DefaultExt = '*.xlsx'
    Filter = 'Excel|*.xlsx|Tutti|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Left = 120
    Top = 200
  end
end
