object zViewerWordForm: TzViewerWordForm
  Left = 0
  Top = 0
  Caption = 'Documento'
  ClientHeight = 663
  ClientWidth = 1058
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 15
  object dxRibbon: TdxRibbon
    Left = 0
    Top = 0
    Width = 1058
    Height = 132
    ApplicationButton.Visible = False
    BarManager = dxBarManager
    Style = rs2019
    ColorSchemeAccent = rcsaGreen
    ColorSchemeName = 'Colorful'
    QuickAccessToolbar.Visible = False
    Contexts = <
      item
        Caption = 'Selection'
        Color = 13468115
        Visible = True
      end
      item
        Caption = 'Header & Footer'
        Color = clGreen
        Visible = True
      end
      item
        Caption = 'Table'
        Color = clYellow
        Visible = True
      end
      item
        Caption = 'Forme'
        Color = clFuchsia
        Visible = True
      end
      item
        Caption = 'Mail Merge'
        Color = clGreen
        Visible = True
      end
      item
        Caption = 'Sistema'
        Color = clRed
        Visible = True
      end>
    TabOrder = 0
    TabStop = False
    object dxRibbonTabFile: TdxRibbonTab
      Active = True
      Caption = 'File'
      Groups = <
        item
          ToolbarName = 'dxBarManagerBar4'
        end
        item
          ToolbarName = 'barDocumento'
        end
        item
          Caption = 'Stampa'
          ToolbarName = 'dxBarPrint'
        end
        item
          ToolbarName = 'dxBarManagerBar7'
        end>
      Index = 0
    end
    object dxRibbonTabHome: TdxRibbonTab
      Caption = 'Home'
      Groups = <
        item
          Caption = 'Clipboard'
          ToolbarName = 'dxBarClipboard'
        end
        item
          Caption = 'Font'
          ToolbarName = 'dxBarFont'
        end
        item
          Caption = 'Paragrafo'
          ToolbarName = 'dxBarParagraph'
        end
        item
          Caption = 'Stili'
          ToolbarName = 'dxBarStyles'
        end
        item
          Caption = 'Editing'
          ToolbarName = 'dxBarEditing'
        end>
      Index = 1
    end
    object dxRibbonTabInsert: TdxRibbonTab
      Caption = 'Inserisci'
      Groups = <
        item
          Caption = 'Pagine'
          ToolbarName = 'dxBarPages'
        end
        item
          Caption = 'Tabelle'
          ToolbarName = 'dxBarTables'
        end
        item
          Caption = 'Illustrazioni'
          ToolbarName = 'dxBarIllustrations'
        end
        item
          Caption = 'Collegamenti'
          ToolbarName = 'dxBarLinks'
        end
        item
          Caption = 'Intestazione e pi'#232' di pagina'
          ToolbarName = 'dxBarHeaderFooter'
        end
        item
          Caption = 'Testo'
          ToolbarName = 'dxBarText'
        end
        item
          Caption = 'Simboli'
          ToolbarName = 'dxBarSymbols'
        end>
      Index = 2
    end
    object dxRibbonTabPageLayout: TdxRibbonTab
      Caption = 'Layout di pagina'
      Groups = <
        item
          Caption = 'Impostazioni pagina'
          ToolbarName = 'dxBarPageSetup'
        end
        item
          Caption = 'Sfondo'
          ToolbarName = 'dxBarBackground'
        end>
      Index = 3
    end
    object dxRibbonTabReferences: TdxRibbonTab
      Caption = 'Riferimenti'
      Groups = <
        item
          Caption = 'Sommario'
          ToolbarName = 'dxBarTableofContents'
        end
        item
          Caption = 'Didascalie'
          ToolbarName = 'dxBarCaptions'
        end>
      Index = 4
    end
    object dxRibbonTabReview: TdxRibbonTab
      Caption = 'Revisione'
      Groups = <
        item
          Caption = 'Controllo ortografia'
          ToolbarName = 'dxBarProofing'
        end
        item
          Caption = 'Proteggi'
          ToolbarName = 'dxBarProtect'
        end>
      Index = 5
    end
    object dxRibbonTabView: TdxRibbonTab
      Caption = 'Visualizza'
      Groups = <
        item
          Caption = 'Visualizzazioni'
          ToolbarName = 'dxBarDocumentViews'
        end
        item
          Caption = 'Mostra'
          ToolbarName = 'dxBarShow'
        end
        item
          Caption = 'Zoom'
          ToolbarName = 'dxBarZoom'
        end>
      Index = 6
    end
    object dxRibbonTabHeaderFooterDesign: TdxRibbonTab
      Caption = 'Intestazione e pi'#232' di pagina'
      Groups = <
        item
          Caption = 'Spostamento'
          ToolbarName = 'dxBarNavigation'
        end
        item
          Caption = 'Opzioni'
          ToolbarName = 'dxBarOptions'
        end
        item
          Caption = 'Chiudi'
          ToolbarName = 'dxBarClose'
        end>
      Index = 7
      ContextIndex = 1
    end
    object dxRibbonTabTableLayout: TdxRibbonTab
      Caption = 'Struttura tabella'
      Groups = <
        item
          Caption = 'Tabella'
          ToolbarName = 'dxBarTable'
        end
        item
          Caption = 'Righe e colonne'
          ToolbarName = 'dxBarRowColumns'
        end
        item
          Caption = 'Unione'
          ToolbarName = 'dxBarMerge'
        end
        item
          Caption = 'Dimensione cella'
          ToolbarName = 'dxBarCellSize'
        end
        item
          Caption = 'Allineamento'
          ToolbarName = 'dxBarAlignment'
        end
        item
          Caption = 'Stili tabella'
          ToolbarName = 'dxBarTableStyles'
        end>
      Index = 8
      ContextIndex = 2
    end
    object dxRibbonTabFormat: TdxRibbonTab
      Caption = 'Formato forma'
      Groups = <
        item
          Caption = 'Stile forma'
          ToolbarName = 'dxBarShapeStyles'
        end
        item
          Caption = 'Disponi'
          ToolbarName = 'dxBarArrange'
        end>
      Index = 9
      ContextIndex = 3
    end
  end
  object StatusBar: TdxRibbonStatusBar
    Left = 0
    Top = 638
    Width = 1058
    Height = 25
    Color = clBtnFace
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarToolbarPanelStyle'
        PanelStyle.ToolbarName = 'dxbStatusBarToolbar1'
        Fixed = False
      end
      item
        PanelStyleClassName = 'TdxStatusBarToolbarPanelStyle'
        PanelStyle.ToolbarName = 'dxbStatusBarToolbar2'
        Bevel = dxpbRaised
      end
      item
        PanelStyleClassName = 'TdxStatusBarToolbarPanelStyle'
        PanelStyle.ToolbarName = 'dxbStatusBarToolbar3'
        Bevel = dxpbRaised
      end
      item
        PanelStyleClassName = 'TdxStatusBarKeyboardStatePanelStyle'
        PanelStyle.KeyboardStates = [dxksCapsLock, dxksNumLock, dxksScrollLock]
        PanelStyle.CapsLockKeyAppearance.ActiveFontColor = clDefault
        PanelStyle.CapsLockKeyAppearance.ActiveCaption = 'CAPS'
        PanelStyle.CapsLockKeyAppearance.InactiveCaption = 'CAPS'
        PanelStyle.NumLockKeyAppearance.ActiveFontColor = clDefault
        PanelStyle.NumLockKeyAppearance.ActiveCaption = 'NUM'
        PanelStyle.NumLockKeyAppearance.InactiveCaption = 'NUM'
        PanelStyle.ScrollLockKeyAppearance.ActiveFontColor = clDefault
        PanelStyle.ScrollLockKeyAppearance.ActiveCaption = 'SCRL'
        PanelStyle.ScrollLockKeyAppearance.InactiveCaption = 'SCRL'
        PanelStyle.InsertKeyAppearance.ActiveFontColor = clDefault
        PanelStyle.InsertKeyAppearance.ActiveCaption = 'OVR'
        PanelStyle.InsertKeyAppearance.InactiveCaption = 'INS'
        Bevel = dxpbRaised
      end>
    Ribbon = dxRibbon
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object tbZoom: TdxZoomTrackBar
    Left = 813
    Top = 621
    Properties.TickMarks = cxtmBoth
    Properties.TickSize = 1
    Properties.OnChange = tbZoomPropertiesChange
    Style.TransparentBorder = False
    TabOrder = 2
    Visible = False
    Height = 20
    Width = 148
  end
  object dxRichEditControl: TdxRichEditControl
    Left = 0
    Top = 132
    Width = 1058
    Height = 506
    Align = alClient
    Options.DocumentSaveOptions.DefaultFormat = OpenXml
    Options.Fields.UseCurrentCultureDateTimeFormat = True
    TabOrder = 3
    MeasurementUnit = Centimeter
    OnActiveViewChanged = dxRichEditControlActiveViewChanged
    OnContentChanged = dxRichEditControlContentChanged
    OnSelectionChanged = dxRichEditControlSelectionChanged
    OnZoomChanged = dxRichEditControlZoomChanged
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
      'Home | Clipboard'
      'Home | Font'
      'Home | Paragraph'
      'Home | Styles'
      'Home | Editing'
      'Insert | Pages'
      'Insert | Tables'
      'Insert | Illustrations'
      'Insert | Links'
      'Insert | Header & Footer'
      'Insert | Text'
      'Insert | Symbols'
      'Page Layout | Page Setup'
      'Page Layout | Background'
      'References | Table of Contents'
      'References | Captions'
      'Mail Merge | Mail Merge'
      'Review | Proofing'
      'Review | Protect'
      'View | Document Views'
      'View | Show'
      'View | Zoom'
      'Header & Footer Design | Navigation'
      'Header & Footer Design | Options'
      'Header & Footer Design | Close'
      'Table Layout | Table'
      'Table Layout | Row & Columns'
      'Table Layout | Merge'
      'Table Layout | Cell Size'
      'Table Layout | Alignment'
      'Table Design | Table Styles'
      'Format | Shape Styles'
      'Format | Arrange'
      'File | Print')
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
    OnBarVisibleChange = dxBarManagerBarVisibleChange
    Left = 112
    Top = 128
    PixelsPerInch = 96
    object dxbStatusBarToolbar1: TdxBar
      Caption = 'Document Status'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1149
      FloatTop = 8
      FloatClientWidth = 63
      FloatClientHeight = 94
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbCursorLine'
        end
        item
          Visible = True
          ItemName = 'bbCursorColumn'
        end
        item
          Visible = True
          ItemName = 'bbLocked'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxbStatusBarToolbar2: TdxBar
      Caption = 'Alignment'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1149
      FloatTop = 8
      FloatClientWidth = 100
      FloatClientHeight = 204
      ItemLinks = <
        item
          ButtonGroup = bgpStart
          Visible = True
          ItemName = 'dxBarButtonAlignTextLeft'
        end
        item
          ButtonGroup = bgpMember
          Visible = True
          ItemName = 'dxBarButtonCenter'
        end
        item
          ButtonGroup = bgpMember
          Visible = True
          ItemName = 'dxBarButtonAlignTextRight'
        end
        item
          ButtonGroup = bgpMember
          Visible = True
          ItemName = 'dxBarButtonJustify'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxbStatusBarToolbar3: TdxBar
      Caption = 'Zoom'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1149
      FloatTop = 8
      FloatClientWidth = 148
      FloatClientHeight = 38
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bsZoom'
        end
        item
          Visible = True
          ItemName = 'bccZoom'
        end>
      OneOnRow = True
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
      FloatLeft = 652
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
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonCut'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonCopy'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonSelectAll'
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
      DockedLeft = 178
      DockedTop = 0
      FloatLeft = 652
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
          ViewLevels = [ivlControlOnly]
          Visible = True
          ItemName = 'cxBarEditItemFont'
        end
        item
          Position = ipContinuesRow
          UserDefine = [udWidth]
          UserWidth = 40
          ViewLevels = [ivlControlOnly]
          Visible = True
          ItemName = 'cxBarEditItemFontSize'
        end
        item
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonGrowFont'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonShrinkFont'
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
          ItemName = 'dxBarButtonDoubleUnderline'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonStrikethrough'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonDoubleStrikethrough'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonSubscript'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonSuperscript'
        end
        item
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxRibbonColorGalleryItemTextHighlightColor'
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
    object dxBarParagraph: TdxBar
      Caption = 'Paragraph'
      CaptionButtons = <>
      DockedLeft = 469
      DockedTop = 0
      FloatLeft = 652
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
          ItemName = 'dxBarButtonBullets'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonNumbering'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonMultilevellist'
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
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonShowHide'
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
          ItemName = 'dxBarButtonCenter'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignTextRight'
        end
        item
          ButtonGroup = bgpMember
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonJustify'
        end
        item
          ButtonGroup = bgpStart
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem2'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarStyles: TdxBar
      Caption = 'Styles'
      CaptionButtons = <>
      DockedLeft = 641
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000002D744558745469746C6500466F6E743B436F6C6F723B4368616E6765
        3B426172733B526962626F6E3B5374616E646172643B5180D882000003144944
        4154785E7D916D4C935714C7FFCF6B29B4D452DC008515EAEB0CB200190607A6
        D1A0633420C3007580096CAB092023B0908D984517B21162AC6C3A15D1606304
        AAC41886C6C807D8D887651F741B41C5B80F6232AC66EC85DA97E71EBDF14918
        59B25F72CEB9F7E6FECF4B8E90B5FF2CA03110116E9F6E10DF3C70AE5C526287
        FF0E3C99FF6DFC943DE5ADBA2069009106D2343046B87FF963E840669128484F
        00401420D5F0B3A0AAAFD8DE28DD7DE742CB45477937E362FE4E8CE1DFC85A38
        0C468499F38D82A3B8D1A6118A448D698AA248220CFB00F8B54838CC78112E66
        84656C707BB1AEF22800489B6ABC8DAFD77E359DED393396D3E4A3B57B8E4413
        73AAD70310B184A0DF251EE56838021038522418AD0E05035785A869DAB02279
        971A639494B8A47A009F0260BA58FEA9C1ED5525A9EAE7EB531F8A7C84D94B6D
        A2A3A4DD110A2EE6071F3FBC7CFF5AEF15168D3E955515921A5BAB98938D7A55
        65CABDBBDF9260D99F5AE2B2AA5AE404528B3F03CFFAA2FDAE35EF76CF00B001
        B06E721F39BBB9FE0CD95D5D64CD74BF0720CEE7CAF3DD3DF03EFDF9ED25BAEA
        DA49F5A2D82F8381A384FE0957328D32ECAE2F022006413581310D3171262C48
        4ADD50757EA9233EAD22C9B91D13C74F62706C7CE80663CD002039DEE9702615
        B653FCDA9D5B0098B9C9B1D6A48DEEAF7FDF58758C6AF7B6B0C99E6E5AB83840
        23454EAA10A5E104205E1F0B86F492437D89B99E5F799B582236A3B8B3EF034F
        278D8E4ED2DCD367D453D742C5A2E05F0158B8F86DEE5ECD2EB7CB065305B1F0
        8F0004DD0C9F145A0ADB94FEADDB9EF42133370B9FF74EE0CB1FA49171280D7F
        007FCD9695B0450058B5FD20A5383BC996ED21F39AB22A0031AD5BCC4EFF3EC7
        E2BDD1269A3A68A76F7625506246B34F52575A795187310D790072F11213008B
        3EBBB120D5F0DA49D7CA4773531DB470CF47C70B8CD4BA599DD7B723121196C1
        1F7403AFDE55601A193FBC8DA6071BC9BBC3421D590A55A64B1FF1B196FE2D21
        6339ECD6C3A07F76E07B45C477AB431A7E098468686C8EDD04101604019CFF4B
        10197CA00D03B8A2AF48E3423D12FE0B9E03EA30520FCBA1698E000000004945
        4E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemQuickStyles'
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
      DockedLeft = 763
      DockedTop = 0
      FloatLeft = 652
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
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonFind'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonReplace'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarLargeButtonUndo'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarLargeButtonRedo'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarPages: TdxBar
      Caption = 'Pages'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000016744558745469746C6500546578743B506167653B5265706F727476
        6161000000018E49444154785E7552CD4A03410C9E192B0A3E8B480FFEE1C18A
        1705C183545B2F0A45BCF5193CFA00E24910547A522F8237919EFD7D1B7527C9
        9899A4D3955DA79BCDEC4CF2E5CB97364208C65AEBCE079F4FCEB95630C1A4C5
        2EDEE936BFE211010CFB87F3EB7C8F0D23CBB2B58EF766E3BE9224D763B0B3EB
        8F5576136C6300444A9BC293864606F28A3F79AC999A7406804645CD08C02009
        3A95B2255F3FD5223C1266A625063EF77D79FB92938380253B682FB0B3FF3040
        A9434CA1BD39376E83D8EC888D880850C3003CE6A0C1C3BB14550AA4FC7B9DC5
        74EE7D0D834245243EDFDD6AFE1923A988C048C806586190662BD538E0E6FE4D
        671EFEE8D0EB2EA73320AC30B05EC7471CD0DD6E32509E7CF4DA8ADC03841A0D
        10195DC67975F79AC728DEA6CA47FB2B090401EBA640328548B5B3A4B5AD30C8
        FF11E2BD6300AA6901A9A4BC26AA0E42C4E502885427A2683033DD9009A460A6
        AEE529B641AA035501F0C77F3FF74F1ED782642711AD0D8A9E1E63958D2FBE86
        ECA00C0017A73B1BF22DBD89AF2CE94D920B36F30B206841CBFAC5FA2D000000
        0049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPage'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarTables: TdxBar
      Caption = 'Tables'
      CaptionButtons = <>
      DockedLeft = 101
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000010744558745469746C6500477269643B5461626C651BFD37E7000001
        C149444154785EA553316B145110FEDEEE4B8282A062215A080A2268B4D2DAAB
        CF4A62A560E92F506CADB4132B2B3BB148E02AB1118E748A360997D80BA74944
        62938B72D999716676F67155401C989DFDBEFD66DECC3C368908FEC752F143EC
        90EF92EEBFF83464A0C7AC4818CCA2513C9246319E190AC11AC5A2F3A29157B3
        E2DEBD5B9700520270C1C7D116AE5F39DD26A34DF8B0F61D3716CF808C1171FE
        D5F2FACDCC8659F065FB3794F602E31F131CDBDA07BBB6E3F6707C67520E397F
        EA88BD215B753221FCE1C6E1C19A45EB21E9C650CFF6E5F3681BE39F1388CFDD
        666F6E7C2BBBB068361A8D4DEE78E7E4518FF9623DC5C3FE054CA704A4E4D557
        DE6D62A9BF0844A2F12B6F3770A77FD9A1B1737585672F775135149B2F6D0AC8
        B0B9B71C1C491903C113112A6A2844EA91C10D6B885BE1989968B6A05F2DA92E
        3D7AFA5ECE9D3D0176659A595CF21903141E41D9B45FC7BF901B12DCBD7D15D3
        03F67CCB793358772ED6EFEAD78335E5AE95437255E1C9F321AAB63571E7AE5D
        E1168BC1143B302ECDEEC6B94C41CCE5AAB468A25A710A61D75A5DC53B100732
        D283C783619DE77B0289843276C1C5C45545D11CFC5935B4A09E4DFFAF7FA2D5
        F80B78A36F0152EFC4E70000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTable'
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
      DockedLeft = 175
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C0000000C744558745469746C650053686170653BE4274AE20000
        02DD49444154785E6D934D88955518C77FE79DFB354E438A52D1C86C1A875228
        4ACCBAE4D038526A6A96499B2844D0A41CB20F285C548BC456969419B470577E
        D444E1A2C52C8A1AE81BAD06CAF0631C9DF2CE3477EE3BF7BEEFF97CBABCDCBB
        89FEF0F0FF3F07CE0F1E9E7314100179200728FE5F0278C08848A0ADD6A5C2A1
        CF87460B85A81C00111011082048AB079DBAB157B67F3904A4FF05E454A4CA9B
        EF791E102448E61008B4B2043E1A7DBB0CE4F71FFB29752E20226D0091B51EEB
        13A6E7C71115324890807721F35C471749C302140FEC58599F8C4D68D8C07B1F
        FE9C0194319ED4CC91BA3A4104F18138CE3331B59CB95A2FC675E1C3DDEC3B2C
        EF5CBB7CEEF5A5DD857380DF7BF86B8900A5B5A7A6AF506DFC459CFCC3C4952E
        7EFC6D0B372EBC8F4D6B6E67D7232B786C6815ABEFEC7BBC67D95D3FEC7CEDF8
        1620676DA00570189B504F6699FABBCEEFE7D7B2B1DCC76DFD4B888918AFA4C4
        4A35FB1BD83AD8B7E0BAC53DC736EF7AB3FFE80B035136429A3AB44B4952CDE4
        E501EE58B6145F2C3051350864A52D541B9E85A5222B97DFD43D53E97F09D89D
        018C765897A0ADE55AE51606CBD75399B7F8D60A69AF13A858C3CD3D8BF052DC
        00E4738068E3D14E1351409B123349A0D27074E615918A8822C17BF001B4F384
        AE025E5804642398F9393336F2E958D99840D45165765E9338453D1104508ACC
        41E88814B3B504A34DB5FD0E921307FF580F1481CE8DCFD4DF9ABC38FDE8E2DE
        25C42680084A29DA2A9614972E4C93D4AAA3808D44C4372BDEF6F2E969E06AE5
        D2F8815FCF4E24692D61413E4201D6F90CD4D9EC9BE7FC72E66272F5FCF78700
        8B8864F5F08B9F0128A058DEFEC6139BF68D34868F7E27074FFF2947BE99CA7C
        EF916F65FDF0A9C6AAADAF3E099400D506F0D073237C75A1D68694560C3EBDFA
        FE1D1F9C7C60CFF199079FFD58D6357DCD53EF9FBA7560E7BD4027A0D6ED3989
        6A7F8A0DC39F9045812FDEDDA6800EA008145A390006D0805BBBFB8480F02FE3
        EF97B5AD9587E20000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInlinePicture'
        end
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
      DockedLeft = 337
      DockedTop = 0
      FloatLeft = 652
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
          ItemName = 'dxBarLargeButtonBookmark'
        end
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
    object dxBarHeaderFooter: TdxBar
      Caption = 'Header & Footer'
      CaptionButtons = <>
      DockedLeft = 518
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001D744558745469746C6500506167653B4865616465723B466F6F7465
        723B4564697494DD6A7D0000017D49444154785E6D53B14A1D51103DF3D67C87
        A4120BFB149A47400206B17C825DAA74219F606D2D7656626F211682200AB6FE
        408AFC43105DF7CE1C19662ED7E7EE6577E7F0DE3967CFCCB0421222D29D9C3F
        DECCBA6E4E107EBC904CD81E245086FEFECFCF2FDB245F5710670691F9AFFD0D
        C723112051F3797CF6B805A0734A351055F38ACBDB7F498D04469713548002EC
        7DFB8C522C5EDA0C00B570AF464C03B6E830131808350DD1728201A093821C3A
        4289664803899A403E1804EDFBE66A0A24AA01943A5AA6818E0DCAA02DB648D4
        A4552C740C0CC338015EB377838B97D768889ED46F238A4E24B052DA0C048901
        86B8252151A686E8B19C676415B7BE2346FD1FA5709CC063B9F6E2FA6FCA52BA
        B44E60F1630D3A35C4D83FA1B4ECBF5288F8A9619D5823063590B505811921D1
        771A0A902DA84E185889191CECAE87008451C04814DB31833936CB2E9B4179E9
        9FEE7E1F5E7D25DA104598EE7E019283E85FFE3FF8E6DF1BF4A7478B1D009FF2
        23A9115B6D98297E76D21B88C13979DDBC414F0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonHeader'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonFooter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPageNumber'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPageCount'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarText: TdxBar
      Caption = 'Text'
      CaptionButtons = <>
      DockedLeft = 788
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C0000000C744558745469746C65004C6162656C3BC22DEDE10000
        026949444154785EA5914D4F534114864729D0A2ADF6C396B6947E5EDA72B1E0
        6D533ED49A0622A685525A04BC1504B5A40282161B892221A0C55668401B4A08
        550413A33B5746F7FE048D1BF7626262DCB8C11C676EBAF06270C3246F66E6E4
        CC73CE790701C0BEF44F8019DE40CCC87384D7412C414107AAFB73C8D69F4536
        F631B2B2CB7B031CD175EEB17B7CA3ABF1D66B383E90DB16579E1059D92554D5
        B384A8EE456409A7F706D003AB0420A81FDF7AD330F10A1C4379300466580235
        87D2C8D4318F8C81E4DE002ED137AA728D6DFD72DF78B9E31CD9045360FE3D8E
        9718DAEFA34ADF2CD29D9BF92FA088EE5B1EADEECF7E6262F9B7CEEB2F803A9F
        D951382F58095CD73285B4CD77F800AA3B832C5D0B78B605442A55752D7ED0FB
        EFA56836758919DE04BA2F076ACFCD3406146BCEDC466A4F820F3075A6B8B9B8
        F6DB1276BD7F0E94EEC17AA1ACE268DDD0D3EFB557F250D172F76BB1582D213F
        A26C1CE7030CFE39A4F3CD70E6E1F693D8E5CFF82CC792D26CE69903030CED49
        903A221192A3705DE3037467A73963F01259428FBE983A52F8C14330B425A166
        600D6A06D7C0D6FB0464CCD577185026AD8DF2016AEF24679ED93FE92DF72440
        42B536E0BB984850262DB74756B6E98BABA03A19FF2DD234D8492E0FA03A3D41
        00A5C6B6D975852BF6119F0FC9981892D545B938159CCFD9D81530F81E80D812
        5CC231210F40E65231212B15CEFC90339737F0FD3031ABA052EDA968D0DA9B05
        4B7819944DF16F02B1B16A3740A86D9E068D770AE44C0C57E9EC216D1280C4DC
        AA56352540D9188763F57150B8C6A04C1FF8B91B5054A87AA4307BC95F1D080A
        312996ACB04B7880FDE80F6847AE0BFC9F87A70000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTextBox'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarSymbols: TdxBar
      Caption = 'Symbols'
      CaptionButtons = <>
      DockedLeft = 865
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000000D744558745469746C650053796D626F6C3B22EE4FD9000002BB4944
        4154785E65535D489351183EE7F39B3A4DD71F1568A4A9606CFEB5660CB22EA2
        1F52240B2A96252C179ABFA029D18514F44B0525E64FABD552532942BCAA9BBA
        0B0CBC0994882EBAE822AC4973B67D3FE77B3BEFD9BE1876D87BF6ED79BEF779
        DEF7BC6794FCBFE8AAC00509CE309FCD907073758C1177CFA4F85DD916287175
        8CDE77B606E778689CD3DCDD9373BB3B9E3F70D4DFAEE039320A97343EFAE746
        DC17A7C8D29759EBBAA25D3755456F079D45991AED53C28B330480A4666FAAB5
        66DBAE70EF74E5CFF2C0F70FAF2E2D7E7A1349AE26C5DD3531EEEA1C878AE680
        623F7DA70AB1A43664BBE7D67E57FBA8EA6A1D0347C3E04B8EA59905D0CACE60
        BDBB7B0A765E7806A5DEA17E4C28F33D26A5E7FCA4C43B62566AA9F00D3F74B6
        04A1FC7C000A8F5DF3A289847D532A37190610A633A2459626F0B00CC67023C0
        717BC31096CAA2BF7F4E180C08A594C8A9193E1415029C7582611083C7D2D78F
        F3D81B0A623262C00C82D8AFF9770BF81E8A0391CA31579CA87801287F209CD4
        E2A3C3441421424E40004488E9BC5260A061AE24684D9F432749A2246B6B9903
        09E10C2882AD0819C9965FE9405C5714C23465016D24DCA2E1901F4BA3BC20D9
        BAD683BD2D8CB65083C5CBFFFCA28D2266C958EFD1558D301E5A24F48463BA79
        C269F6FAFEA9725F004A1BFDEAF6C33D0738968A9CC9E71DECAA293ED5AF16D6
        DD85FCEAABD31CCB345B103D7F7BEF6F5E092DFA81114BE696A2B7F947FA7AD1
        15A3A8EE7AAF252B67468BC52C2CB6FCF4C76CB029F926A7F3794341CDE5A31C
        D898BBC77BC87E76040A8FDF8384CB9A1D9E4128F60CC066E7895A8EE5E4EE6B
        3999577D03F92C9C420AF66ADDB0EDB5FDCC304114C4E818410E3703A7C03FB6
        82BDD3B6822A71819548182959463E168E5F6B30CC718179CB05A02E87050688
        2502E23CA3099734545BF597C612A2092003F9248E24F895BF0F1F5BC909A5F9
        DC0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSymbol'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarPageSetup: TdxBar
      Caption = 'Page Setup'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
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
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem3'
        end
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemSize'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem4'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem5'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem6'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarBackground: TdxBar
      Caption = 'Background'
      CaptionButtons = <>
      DockedLeft = 440
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000016744558745469746C65004261636B67726F756E643B46696C6C3BB4
        301774000002CE49444154785EA5926D6895651CC67FF77D9EE76C1808F565D5
        022B04539372E569B3A1C64997494E042B674C8392A03E4CE9DDB276F24B3456
        B4494523D68B4210522D1015365D63A3068EA65030AC6D6E9EED6CC1D9D8CB79
        9EF3DCFF7FB0170E7EEE0717D7A7EB820B2E73BEBE0A0CEC387ECE0006B04BAE
        0B5EC070330A445E1844003425EF96F5752D372418BFD34D0EB0E2E1E7C9FC9B
        E3DA7016510308AA0654500C5194FBF5F82BDB929C39BA0555E5FDCDA58986CA
        BBB4A3F105D528AD3DDFD46B1004EA9C531151B72CB7A854539702C5DEDEC64E
        43A3897D76E8A14DABD76EA0F3BB9F595D9924B1EF209DAD29363EFB169EEF23
        02C6C65848C50D2E12006B01AFA9E681C325B7AF6ABEF5DE7236EEAEA6B9F625
        B25753945525F9BE691B2D7D15740CBDCB6C6E1A27822A44CE0118DBB077FDE1
        FBCB2B4E56D77FCE83BB9EE4F1831B78B57517D98109AEB51E637BE239F26D33
        74FFFD356D7FBD4698CFA302415E00B0C5682AB1FF08C6F884E36DCC8C5E24FB
        E70499BE618CCDD379AA85756B8E901ECBD13B7886B9F9699C2A2E8A008CCD64
        E73FEEFDE134F323A7991AFC85C9FE0C23BF0D128B09DDFD596EDBFA32EB92D5
        8C8E044C657304F910552D4C48B5FFF3C9D96FBF3AD1FEC59764FA2619EAB98E
        5F64B974658A921D753CF2D47EB03E6337428AE6D6108FDD8213C539592C00E6
        3EECBEFED1B90B630D3DE7D358DFD2DE3F4DE9CEA354EEA9C1FA45A8B1AC5AF1
        28DBEF7B1BCF8B831AA2E582D4E65201669A2F8F35CEACDDC71FE995DCB3E775
        1E7BBA16EB17E304E2F1624EBEF1135BCAAAB0310FA7B23C01CF858EF736DD21
        F5BDE9D992CA1A761E7B078707311F271650ACB50B2500AA1655967F60BCA52D
        00AEE3F7519ED95D461809A28082A2881A540514048388E04400F03EB83C0EC0
        09635C303F7BE9C5377FDCAA4B411444C018050001018C2A6130DB05E43D0A84
        A73E3DF004E0039602A6E037110239A3AAFC1FFE0357C2717D9C77D8F8000000
        0049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxRibbonColorGalleryItemPageColor'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarTableofContents: TdxBar
      Caption = 'Table of Contents'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTableofContents'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonAddText'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUpdateTable'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarCaptions: TdxBar
      Caption = 'Captions'
      CaptionButtons = <>
      DockedLeft = 228
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertCaption'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertTableofFigures'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUpdateTable1'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarProofing: TdxBar
      Caption = 'Proofing'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000017744558745469746C65005370656C6C436865636B3B5370656C6C3B
        53FC4602000002E349444154785E65927F48936B14C71F9DBFCA19DDA925534B
        9D3A6D9BDBEB720ABAAE9BEE75BB2A9A9699962204A636B2A566D245B952C1D4
        98FD7060964ED3A20CEE3547F68722256AA2E62F340B94B21FE294A4A4A86B9E
        DE07DED1C60E1C5E5EF83C9FF33D0F0F9290258A28D5799028CE92FE3CE5F648
        653944269C03715CB16A978FD09190A9E5118A52D84F960242C81E0090652309
        0587CBD4A911641950024F0C7204C9FE62450978ED8D700B8FD3E0832E543B50
        6D6723C0A01F4FE54F819420914DC8CF00212B0681B4B0D2831DF68730F63416
        3885C5AA112E1B818882451484415FAEC28F02614F488248F0E72970670BDCF9
        078AB080892578059C02A7A1FF1908833EDCF8600C7A07C97D79D242E0490B20
        589273C8DD5BE81A28CE2643A3F30137967805495CD32B7BDA73752340AA0D7F
        E1548ED868F175A6DB819EC6A0EF609B2F5FC64AAF7CD2D534F00E7ADE6C4076
        EDD0EF5D70656B07D1FCFF80E67E6CA1D9EF5B68E6DB4F34F57513E1E89CA834
        4F6AF240F3F07BE89C5B873C6D3F08536AFFB612D0D39CE834F6E6C3DEFB6259
        072F189FB68F2DC3DDE935286A1886B0942B068A71B3143048758BEA58DD1024
        971BBB88240D875E8599A079D87573E02DB48C99A0BC630A84A9D7469C99BB3D
        B0DC52E092553308C685CFD03EFA018E54F77D8AC9A93F292F686BAC33BE02C3
        B809AAFE7D0592CC9B1F77711379F88EF8297A642970921CD5EB4ED40F42EB84
        097A97BE80A669146ABAE7E1CEE42A5CEA5904695EDB265B785C4927B30B4DBC
        6125B0C3718934DDF5DCDA6750D3BB04FFBD5E07C38B15A87EBC08A91546F08B
        2ED36206B3F767D7105779D54A80E887B2839FA4D5675DEE87AAEE05A87CB400
        F9FAE7C0915D1CA7004FCCDC9B594577264D2888D4590BC49906B364E73EE5C5
        C68CEA3E287BF01244690D1BAC00528AD7EC985E45AD132BE8D6E8320A8CBF62
        2D20329A1171F8B659C20A21FF698AC9EF04365150618ECE91D7A1008BB610D8
        1403AF43C766D2529BFA05BA6881B1E52780230000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSpelling'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarProtect: TdxBar
      Caption = 'Protect'
      CaptionButtons = <>
      DockedLeft = 127
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000023744558745469746C65004564697452616E67655065726D69737369
        6F6E3B53656375726974793B7B1AED18000002BC49444154785E7D936D481559
        1CC69FB9CEF5ADFDB21242452DF6C252081A15921A15525C5358F083517E504A
        8C34CA97726BE152A1469A0A05995C83BD2C1141118A5251525CBD698295697D
        C92C0577352B6FABDE3B7367E69C7F67864154C2071E9EF9F2FFFD9F7386233D
        A8FA0323A353070DEEF8676C7CDAF9F9DB74FFBB8950DAE0C4AC0E2122C2B2BA
        7BCE85EADCA4AFAF3C0574253F950A53D76979DB56D502700ACB66DA8E148EB2
        BF1D26D8B41C54340466D468FFC047B872B7436EE5CE976311957F79DB2BE190
        41C4C139600D7042381CF65F2B49CB00A0C1965499BDA5A3EBEF220ABEAF274F
        D91E6A3A5F46AAAAD2CF54DADC470062E71B40488E8CF10C0F7DCA8A961504E7
        082959FB31A73268CC0081A0330211AC016ED6011C3B734EA3F77E3D1CEB73E2
        631E6F99CEE89C9D0879DBDFA25BFF8E6781E7088682D0058013ACEA9CB83081
        310B2019222DD2CAE45FAA0FA4A79DDC5BB42F76F5B164C4B9E2F1F4BF56B4F8
        1AA12A616BE8EBF719D435DDC1C1E22A0C0FF660C38EEC35DC06C80EA794F7E8
        750F38B3EA091398C8A7331D38B2AB1C4E168DEBDE362424AC85E7E821DC6BEB
        C4D4BF63371963E9569585BF4638E658C393C99AFCADF85F61703AA3C0988182
        B2CBB870B618672F5E85DB4C7783F6B6D31307400511CDDB049C68EA25539301
        853E8C7FA1811B8769A82689062E2452BF7B33F5FDF93BF5546CA487C77F7B01
        60858CC572D867B38EA28575447C7B87C492DB20A600862A1C02E941F8EA4EA5
        00885C0A00E364A508EBC60D9D0186027A7309B75ABA91579002E20698C12024
        2D05B07068CE57D8D8B59B138732378B0ADD30B70B1B18F9A25AC3E04C80394C
        2D0568DE73AE4CB39A7DA9BF969ED934023D04620CEEF25440004800B8000BD1
        2200119958C5362449D202B3BADF575B94CE7406A673EB585CC06614E607A0C9
        585E6A66F3A8CB6E242DDC653F26F507A124B4B097E1BD620000000049454E44
        AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonProtectDocument'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUnprotectDocument'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonRangeEditingPermissions'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonEncryptwithPassword'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarDocumentViews: TdxBar
      Caption = 'Document Views'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000011744558745469746C650053696D706C65566965773BA37184340000
        01D049444154785E4D92BF4E1B4110C63F4BFB1269524534209FC903A4401448
        2928A0C5928D0D18625BAEE02D6C4B2601C7890181444545610941418F7CA4A5
        4AC34BF87616E6CFAD59EFDCD833DEEF373B736E747D7B1F42584100027F827C
        111F4008C43135921CF106F1238407C787CB1B6B50015DAC21725194ADA08201
        313EBEBC59714C63EB8CFF818402F42A45B446CF4264A80F84E37A82C6692A15
        F910F06B7719048213022007BB9562A4F76BC548E2CD622CC2E99D9F53A68A98
        03F23B137459E9D14B3FCC17244F2A28E63419D0AD26F17E678FAFC8328F59B4
        0CB39947677D4184860DFB2F111C91625A7F52F4B7B5C4F2B74F00F1CEC9760D
        28A13A4831DA2F49DC21F64072123CBDFB1FC919D33382F71E879B8B563ED964
        B889A457F838EFFAEA6725B32A846CE24AA1BC47B107D6149B28FAB72F4A6732
        65F05E858E36974C98A2A0CBA9835A2956D0FCFE259210E9F37EFC6D7E9D0BE4
        89C6706A73D684ACD8B88209B007B6FA4FB868BF8B9008D0FC3D97AD9E54C1B6
        1CD69C00ACE990316A807DFD642A7EB897A0769C0ADD938A8F7F2CA3DC7B82B7
        9E813D018E9F4C38D92DD9BBAFBCDF0789FD0672EC793BDE5D635241A0C9F8EA
        664D664B3A5B126F96C76131CBD92B3D7903B2B003B677363556000000004945
        4E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSimpleView'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDraftView'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPrintLayout'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarShow: TdxBar
      Caption = 'Show'
      CaptionButtons = <>
      DockedLeft = 196
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001C744558745469746C650052756C6572486F72697A6F6E74616C3B52
        756C65723B6BC8E036000001A249444154785EC593316B54411485BF997D2FE9
        923656B150B0D2C24EC114BA7FC17F939F6063A32058198B602116895965231A
        41240B112C641B8B40C040C0276F93F776E6DEEBE40D846D02C2165EE6CC9973
        39738681196766CC539E39CB013E0337DBBF9C2F4A81E0BE3FBAF3C1C19AA9A1
        09D641BB359658141103CBFDAC9526E8E7FEE3F1FD02B3B5EB0FD773A0196089
        6C56679802A0F531CDD19883EDEDBB4059483B0514A9C697DC30CF16CF88273F
        89BF0F995615B16D005C11DB904FCAD63C2EA4C34243AC0ED1EA086B6B9C4C71
        BE87B4310748144C03EEDC2C116283266DCD1F7472D26D2234586C3A8FEB15F8
        1E6834724010E2F10FE4D73EA07C1C8CB8D7BF0D92838783031EF46F25678973
        9EAD3723FAFD9B8808003EC68835159F065F13D79828C5D20AC39D1145AFC4D4
        51AEDC6067EB1BBE5C0483852BD7303500E7352A120435C32DAF6289457C362C
        5F45134B041383A5D54EE3173A1F803F6D6577FFD526A7B5F165F32D752DECBD
        789DB4B0FBFCBC1F183EDB6092F8DD930DCE26C2FBA72F9904DB0382031681DE
        CCB376FFC00604A0F9EF9F69FE80BF8C441365A06782F60000000049454E44AE
        426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonHorizontalRuler'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonVerticalRuler'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarZoom: TdxBar
      CaptionButtons = <>
      DockedLeft = 351
      DockedTop = 0
      FloatLeft = 652
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
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarNavigation: TdxBar
      Caption = 'Navigation'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000011744558745469746C6500476F546F466F6F7465723B2E2AF2700000
        01C849444154785E85933B6855411086BFA3624082622B0AB9C6CA422BED7CE4
        062456568285DE085662210A8A85DAC4C6424404410583365A6823161646C4CA
        324A9A086AD4C25A4173CE3D3B339EDD1D30D7CB210BFF998161FEF9E6C01466
        C6FFAF280A6E3F7965AA8AAA10A3844629174494ABA78F8E9AD9EF75F8BBFEFC
        CB9C41D7D49879BA08FDAFECDBB3937E1DA8FA8D9A584705E1FDC222C006E09F
        8119DD4B473A005455C5BD674BBC7DB780A8B82285A0A6A88302B801A8AF52D6
        8A58C1B1A9BD94FD3AE1AA084124AD71EBC547EE9E3FB405F8396010D1011EBE
        F98E99A118A68D00554B93A727C618DDFC2BD67FE06F88E0F8FEAD50904D148C
        9C9B1589527C508B4124F8E6D3B381A6664D26BD6E07116D31F0C28903DB5003
        234DF5759C42415723987DBD940D7C6F5F25E52727C7116D25B04C7070CCA747
        D1C8D7A088B1DDC00BCCCE7D46351B787443E84DEEC0565BA137D1C9CD060639
        4F317F445A0CFCEF7AB3B17C635326101021E51A8C73627C3883EDBE2383B7A0
        CACBB3F7E7A7625390C04583EDD333104A9065A8FF40882A997FF478F8166E9E
        DA7578C5358E5CB83C527E7A7025216B0015459D84A8815B185618BF566D04D6
        036B5668ADC7DA6F81BFA89E834DAEDE54500000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonGotoHeader'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonGotoFooter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonShowPrevious'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonShowNext'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonLinktoPrevious'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarOptions: TdxBar
      Caption = 'Options'
      CaptionButtons = <>
      DockedLeft = 404
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001E744558745469746C6500446966666572656E744669727374506167
        653B506167653B4166DE820000020D49444154785E65CF4F48556D10C7F1EFB9
        E7944251B4AAA8458150D1FF76DDE212D142215A0551AF104ACB70555A6164B8
        08058B245A484594B5296A57EF4A34D4C810EC0F41AB40B7416176EF3DDC6766
        F23907CE55CFC030ABF97D6622336369F53CFF02809AD1DBBA3FEC793A3D1204
        61494C5131547D2B71B53C79E7E2B113112BCBE066EBBE0028008D2252EA3CBD
        135143542108288411BD4FA68BC0AA2CA0EBF10C402200852B0FA7465894AB4E
        E979F615496536AE0F397BBC09110308A3A5727FFBC14C764E4A37FEDB9D93AF
        0E7DA01AC78848026501629AC81DF7DF2FCA8552C5299D8F66525994CD1B22DA
        9A772472CD09E2AC1E102C565D76A5BEF64339B9637022919D084E5C32812002
        12F9CCF091110A56FAA95DB4BD56D4CB666C5BBB8B8EE26D449454F6537DF8B2
        1742BFDC7DEA1A6A0E35417088397A5F0CE464BF2CA2CB2E08BCE097BF57C618
        EF5B43F1F23C98653FBB9A97D3C5BBC31F319802AAD90BEA534D989B68C0A9B1
        B5612FB39519342FF3B2FFDC01600EF853BF20F959D872B8CCA737058FA71768
        5DBEF560124DE55933FB05905D205E3087A9B1B050C63094242093FF1F3C9FC9
        A44576818A61383EBF8DF95BA930FAEA07DB9B0D1FDC7D6F0CB5E5722EC00B62
        8E3D2D11C5934DAC8B36F1BBB61A1FFC6EE8C20A391FE0E2726DFCFAF0C05155
        256DC30CE2F95A5ECE07108F5EFAD60234022110A40D405C97F3F50F32C28CD2
        9B0122C70000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDifferentFirstPage'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDifferentOddEvenPages'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarClose: TdxBar
      Caption = 'Close'
      CaptionButtons = <>
      DockedLeft = 634
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001D744558745469746C6500436C6F73653B457869743B426172733B52
        6962626F6E3B4603B9E8000002AD49444154785E85934B4C546714C77FF73232
        0C041DC2237644C368F109868D98A0290BDA60E2DE9526921856C3C2A08C2E1A
        A336A64DB48D81A8892D6E241A7CA20B1530261849DA4D47596818082F015118
        0698B973DFB7773EB1333BEE97FFCD3927DFF97DE77B1CE9E3AF17293FF3B30C
        48426B7D9939765A1290337AE1DC4B8F2CD73B0E802306C24CEB9BE7ACFA6206
        86650FECFCE55283079025DBAE2F3D5CB79A94B58E206692C5CF1606933DAF7F
        006451BA69986099A8C3C38C3C7846D791D3BCB97413351A151AFCADD38D8589
        DE7F412A3A426A388AC801D92300A689E36A2A1225129923D8D1C9FC9387FCDD
        D587244BC4037BDC581B91AB97716C93F2AA6D989A004802A0AF28382EF19F3B
        FD34F4F7515852C4E2AE20FFFED10140CDC9101B0ABD54B4FFCEAB1F7F62D3F9
        0AB4643203589E9C469F9926B8BF8AF947DD94B5849072246A5A43E040913F9F
        BC75394C3DEE2658BB9BD4F07BE2E3B35915A83AFAA719766CCDE7C3403F43C8
        6C6D6EC65FE8C391C0B660E8FA359203BD546EF7A34E4C60A49C2C8066602514
        B4D94F98F12596150DDB721043DC84CC4A3A168FA14FA75CA085A17D05885B30
        D280548AE8FB39947D8D048E3661D936DE5C99BC5C8FB0BF3BD684527B88D1D1
        18B6AAE22E9A5D8186954C105B50680C87503D3EF2BDEE9E6FFD0940F9F11380
        8FFA700BBD4FEEB2A94842D73D990A74DDC45C49B2A37A336FDB4E5122AB8C5F
        6FE7CBBDDB7C763571A39D328FCEBB702BDF6F2FC352750C4DCFBC0343750189
        243E3381131BE369DD018A4BD71328CE136730D7D3CDD3CEBFD8B2A518AF99C0
        4C030CFEDF82EBE802602C2CE22DC8676F7500633981E2DE0C1694FAFD6C2C29
        419D8FA12515B06C4C43461080822B6595CF7D927410475A3DF9ACA6B0859FDD
        50C2566C7BF0ECD258A3E846200FF066B5AAB4462B3B800628FF0122CC6063F4
        5F96130000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonCloseHeaderandFooter'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarTable: TdxBar
      Caption = 'Table'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001C744558745469746C65005461626C6550726F706572746965733B54
        61626C653BE8BCC9780000028B49444154785E7D536D485351187EEEDDDD1659
        DB8A28CA4A42D13EA42242A1B2C2C04C8AE85F100446118A5056F4CB3FD1AF12
        2C0A414D34FB02354A08A33233675FA666E5B048932DC5A9B9DCD6C6E6EEEE79
        BBF7E4F426D803CF79795FCEF39EE73D9C23E495F58211815456E4A7620E083A
        8A872BB7151A4CC2210212244D5C9EB741D46D802E8A2F8B4F1CB0C6CDAB5714
        068D11398AB7811118B7C663CB9A54F08EC7AF7F6A2608BB1923288C6199D588
        B4641BA2C30EACF8D5861DFBF7829408143982483804DFC4042E74DF46D2C644
        480004A68AB3D2578111B0D02C62E52203BCFD5D10C65B9191BD1DD18007635D
        76CCB799110E0410F4FBB0DE1B85BDC7016E9D18E362CDC192380163BD1DC0D7
        46EC54C52FEA1E6072B807D6E44DF00C8E223A1984228760F501038343BC01BF
        C4BE1F3F6193C218ECB6C3D8FF18892909B8537205E96909B0B7F420E8EC842D
        79337C235EB806DCE8E813E1F705A1C178FE96833484C361BA5970905C4DA554
        7EE608B536DCA38ADC741AA92FA087E772A8A928932EEE5B4B978FE5504D6337
        018897A081682A10BFA8BAFB2D38595C055114A1280AEA6A2F615DD252740D99
        907BE3392C160BEEBE7603805F8A8DF0A87314AB179B907ABA1A82007C7085E0
        09C8589EB2070B76FD46DBAB0664145EC3977103BE3B3CE8FCE6450CA6B3D59F
        498F9A16D774A23AE0A335BE77922CCB1443EED57704C022C6ACEBC166723E86
        D96CC690972049DCB07EEAA9774084867637FC21195CABB2BAD905C69B69295F
        50F6CCC90F23028FB1176B3E55F991F4A86A76D26C943D1D203D8E96BC210056
        51E767B6BDFFD768E6D318F34BDB9F889294A9306E6DC6262330A8D4EA88D518
        D7464281B6DAA2AC6C21D6048061D6B7C5DC91430610FE03D322A31F5383B2DB
        0000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonViewGridlines'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTableProperties'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarRowColumns: TdxBar
      Caption = 'Row & Columns'
      CaptionButtons = <>
      DockedLeft = 152
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000021744558745469746C6500496E736572745461626C65526F77734162
        6F76653B5461626C653BD57466D80000022049444154785E5D533D685351183D
        2F8D89A6198A436D53709120884A6A8A1471B0626C1174721207755074147454
        FC9B0511A90A22888BC40E2E8D8393A0586B8AD0254A4187D428A8D5AAFDB1EF
        5ECFB9DC9B9A7C70F27D5FEEF9CE3DF7BEF7A22BE5F75058C158971F8F4FC3C7
        49E20E81037B3773DDC0580B630812AF9FD80E78818848787410C9ADC7CA77B7
        1D1FB3CCA300D2C45A621D91F17DC2524C83D1A547B5674C435217BE7EF981E7
        537528D8627721876C57860E80989CE5A58517B7CE0CEEA3C0425202E40C5D38
        9C87A231B788AECE148022769E7A8257B70F39910F9F7F239FCBBAFADCFDB7BB
        00AC219C80945DC84175660EA5FE6E1223D7475124066AF55FD8D8DD09D9368E
        8F44387BC7F4D9CC8A481A023CC142640F206C14EA81D1A5F55CFB1E8E804D47
        AF916088984E6240B5C0DAC4EA995D6FF0B17C236C0E0AC8A57583CB8DD76041
        227BC2B066A3AC7ED5116C8B0040EB330F2F32FB252B1D5F1BF82197C5D564AB
        830785095C3DB2057F638BCA5403A5C206885B79338BFD3B7A5C3DCE7AB83F27
        3D9CBF57053018859B8CFEDB810839000EC65B0FEE34DB74A0C577F579D4080D
        3DAD7ED2D1E15C4CCEC2F1E562B2EE5F6327B0EA40E47C6F96CFBF4764E65E67
        DDC0A254644D4878B8D88791813E3A68BB03132E4C36FD8D1BD7EAA7E59D103D
        3868AAA44FDF7C5949A6D27BE2E6E303C16C4C4B1F44FEFCFC363176F9E0885E
        A4F015A68470A476B4FDAF5824E629B0F20FF7C68559C2C6F29B000000004945
        4E44AE426082}
      ItemLinks = <
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem7'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertAbove'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertBelow'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertLeft'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsertRight'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarMerge: TdxBar
      Caption = 'Merge'
      CaptionButtons = <>
      DockedLeft = 465
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000017744558745469746C65004D657267653B4D6572676543
        656C6C733BDFCE3B44000001DA49444154785EA593BB6B554110C67F73EEFA00
        1F209884A0B7B0898D04F1018A924761E59FA0BD858DA5AD6027888D95451A51
        84205805629128D74A2410141441410DD104440493FBDAF9BCCC653985450A3F
        CEEC2CDFD9F39B6196634003B0889D457D0E01B2DBF71696CD1AD3145760A6C8
        452AAB0C701459E4DC7F998C6AFAC6B5D9308481C3CADB6F9C3A7114D5B578B3
        FA85D3934DCC0C0418DCB9FF7C2A650949F4FA8E048DCAD8DAEA9011E6A53A6C
        B7BB38808743AA2A9A470E61B7EE2E68EADC045FD77E0675F4F07E9EBEBB026E
        0106475420101E5ECD11C925CE9C6C32396899201BF3ABCED5CB97A8A5925019
        A360EED92249B9F459BF7517426CFCF90E52395F18186264DF389E21B9C3ABD7
        9F585BFF05C0D8C801FA2E24216510B88105BF7CAE0877276539E7CF1EA3D713
        32D8DDA878B202222008475E57874080844B2445B5A086290539F6A38336EBB6
        23D72B2267276577965B1FF8B1F91B09C6C70E925D3C985F248050AE13214C90
        0515E19124317361826EDF01480DC3FDF1C03B4EC8082DB5DE337B313C84C56D
        CD3D6A91DC1D17A4548103824E2F2351B72B687732EE56AE3006FDF1F30676FD
        E6C3A5B46BCF0CA83C11410809C928A4D82A3C7ADDF60B03F6026987BFD1F857
        02FA2689FFD15F654423D8B259E1820000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMergeCells'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSplitCells'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSplitTable'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarCellSize: TdxBar
      Caption = 'Cell Size'
      CaptionButtons = <>
      DockedLeft = 632
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000021744558745469746C65005461626C654175746F466974436F6E7465
        6E74733B5461626C653BA79AF4F30000019049444154785E9D903D6B14611845
        CF3B3356E21F30A5FF606B9114F662933A858896BB7E90462C53185C10454550
        B08A8D60235AD9043F9A2062AD364921A8088A5992B947989D605842849CE6BC
        F7C2C3C3F31695BD2C8EC61A89192BA32437A343234FEE2E1566A89821095162
        466D1B92AC98A0613F9AF34B77D414633FE8D86425C19801BA1E9D4B7279E1C2
        321212D0F8F4C1B55281A006546DEA7A54D7CD66CCC064BD8D83BAAE369BA619
        892A534947A31229F4CDD6D6E44674DC6D8E03C9FA64D2CEA1C3FA485D54040A
        9D98FD44162E2EAB629C8BD9341C1737549E3DBC5E98A1610613125187E21565
        2841D9970254BD0B53FE6F1008B0531696DFBC92329F480C4948BBFB96B47DA7
        5D6FDFEFEC4CD65EDF3E7BBAA154F3674E9D4021884AC2D40A9DFF650523ABCF
        DF9F04EA4645E0DBAF6D1454C0CE7D464401ED334847D5007CDAF8CED71F7FFA
        ED10C54812DADE8944A6E721C894AB8F3F3ACBBD179F0FCCAAE76EBD133856A1
        1C8638751365756D839FBFB7D9CBFD975F0ECCDAA970E9D187439DB0387E2B70
        F42F7460E2F5A35BF3570000000049454E44AE426082}
      ItemLinks = <
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem8'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarAlignment: TdxBar
      CaptionButtons = <>
      DockedLeft = 744
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000003D744558745469746C6500416C69676E4D6964646C6543656E746572
        3B416C69676E6D656E743B4D6964646C653B43656E7465723B4D6964646C6543
        656E7465723B8CE012DB0000016B49444154785EA593BF6A156110C57FBB592B
        5FC3978804BC62212A3E87758A40445218102C149F40B0B2BFDE3A5A24E902D6
        82EF10E58AF74FEE9CA36406F6835B0471E0F00DBB9C39BFDDD9EDDECDBEB3FF
        F44E0F74256E38AB27804D07F46FA7DF4EFA7E6742950C96908D948A102111CE
        7EBD589CBF79B6FB0060E72F85FFB50EDE5F18B83D34482CD6990A64B28D0DD1
        90C8E6C77C458400FA81A68CC1465066133232D81E1F096A005C13B8525D379F
        BC382B83905221313DBE4738E94202E886C42D6C67F2F4F82E56A2672A39C423
        99621CD0A9081E1F9DA2306E9323506D40A58F47133649404BC0A7977B586E92
        4BA6CED4CF5F2B22DC10D4343BCD8F0E3F23AB92934012B3D70F13DF10F2F63B
        0819DBCC5E4DC6E4DA848B40A2889A2D444BB08D5DE671A001B5049BDAE9E57C
        95A6A272ED3D0047196BDD45E001D07AB9FCF2FCC3D7FBF9BDA7B2F7F5A9E6BA
        8A70F97B7E0E5CD5DFC5AD5257E286DEC015B0E86CF33FF507E40EDD06B8303A
        0E0000000049454E44AE426082}
      ItemLinks = <
        item
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignTopLeft'
        end
        item
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignTopCenter'
        end
        item
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignTopRight'
        end
        item
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignCenterLeft'
        end
        item
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignCenter'
        end
        item
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignCenterRight'
        end
        item
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignBottomLeft'
        end
        item
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignBottomCenter'
        end
        item
          Position = ipContinuesRow
          ViewLevels = [ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarButtonAlignBottomRight'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarTableStyles: TdxBar
      Caption = 'Table Styles'
      CaptionButtons = <>
      DockedLeft = 838
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000001974455874536F6674776172650041646F626520496D616765526561
        647971C9653C00000013744558745469746C65005461626C653B466F726D6174
        3BEEACCAE3000002B349444154785E85926F48956718C67FCFFBE784D88C73F4
        38CE6665C64116B83F6D945F1483881284091BA34F456BEB43CC0FD22008FCB0
        8D82DA87C6289B6EB2898233C336D8C436B5E9B4DA87ADD188A58343E599A566
        9D3F74F49CF77DEE69EFCB8164633FB8B878E0E6BAEE1B1E059880C17FA3C883
        F872651900EBDDD323C3CA306B119027124F5A10BC7745C001D18880E3E6463F
        38D2B013C801585AABDA37EBABF0C6E1D6D43C95D112BF58B83939C7C1BA4DF9
        3D4E9EB9540B98F9805CD64510E6D2391021762F492852849FC7ED99248EE322
        286CCBA0BC2C08602AA54C40D4DE0F07E5D5AA8DDCB99F4294E09DE23B1E2FAF
        D3084255E5733C7898A4B8FB78FBDA80FDC68DC189435636EBB0E58552C2EBD7
        8128AE5E8B515D5D8E1285208C5F89D158FF0AB669A0D0FC76EA2BC2E1E03B25
        353BB8F5FD4FADC6CA0988207E9DE37AD55E276857639906AE9BE37AEB092289
        694AEB7632D6F60503F1E96F557DF305D9BE2DFAE4D63C7881026CAD08B13562
        91BAD446E9749CE89ED719FDBC839E81E1DE1F5CE76D0EBDDF258F924B32B790
        91D9659DF9726CC597B5280B894519BDFAA7F4B475C8D8C72725D1D329FDBB76
        48A3615E0C4111601839C7F556C5438BA00C85650AB9A50CB15F4678E6F92815
        079A681FF895F61F2F5F18D1EEBE0548EF016D6532E9B1A663DD35080842D1DA
        0206872CF4EC4D8CEB9DD80B9354BD35C9479F8ED277C5EC4F611F5C249B1211
        5DA714008540100801C5C0B3FB5F2A6C38BF7FF3E3A9EFDE9389967239B73B24
        25154D5D66201C040CFFB7F21A8088E40598B51BD66CF8AC21FC777CE2A824A6
        BAE46C4D8134BF1898F5C38D55F3583C8DBD7BA3FD4974DB9648E26E9ABE96C3
        CC241DE2297D02488B886615AB03F4EFD399BEBF3AC76D839FCB965CFE985F92
        DE81B81E02B24A29FE2F20F775CC3D0F7C0318800B647D17FE857F00273C6EB6
        B34173A40000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxRibbonGalleryItemTableStyles'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem9'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarShapeStyles: TdxBar
      Caption = 'Shape Styles'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000030744558745469746C6500466C6F6174696E674F626A6563744F7574
        6C696E65436F6C6F723B466C6F6174696E674F626A6563743B7AD16B1E000002
        3D49444154785EA5D25D4853611C06F07767A9FBFEE86BF991F3E3B4746EB5AD
        D92E02CB357573B118052115215418C604C50826495999ADA2A422F2220AFA06
        FBD0928518D445D1A51883D020A48BAEBA29E8A2FAF79CD7B3718849171DF85D
        1C1E9EE77D0F1C46443933379B16854705022C0135A81E1E7232E5C0BFCA052F
        4E064E4DF6D7D3FD84EBB4F40EAA45077E7EEEE1995C2E9C381E189C7DB2937E
        FDFE483377B6D370DC7E46BA0D2F3AFCDBC8B1214A6B7C92568890E80D732817
        3DEBAF1FFA301AE7E51F73097A9574512AB44ACA347C402A296EA23C593376AC
        FE6CE6418C97BFCD74D0546F0D4DA53653B7D7720179212F8838314F59FBB8CF
        7FEEFDED282F7F7DD74E935D22A50736D161B7E922721D08BC50E509D3DF273F
        4AFACF4FDF68E1E52F2FDB28DD594963C98D74A0C6308CDC00C2BE9222C64BD5
        EB9A9403EADDB150C3EB549897E7C7E334D161A7D11E2FB58BBACBC88D20B4D9
        0AD9DE6279A0CA1D520E683C5BBB2F3DBD3E48DFE7DFD2F38376BAD759477BEC
        DA2BC84C20CCDD8DB01DCB0AD8FE72CDC240455D503960F4351F999D7E93A65B
        4347E944A348BB4A3557119841C88C045966A491C52C6AD625EA1706ECCE2DC4
        D53690748AB52C48265BE093CEEABC56663606B3DF1C35A999A4D528B008F4B9
        8D7C2067BCD7C3E45FD50C56D0CBEFAAB041602D7A813583349210756CC06B66
        D96B6B4127170C6092472CF2D052580E2B6025D8A0185D79204F0825500AABA1
        1C2AA012AA4104476E205F086BA1169CE00237AC072FF8C09F1DF82F7F003A7C
        7F2F9B1AF61E0000000049454E44AE426082}
      ItemLinks = <
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxRibbonColorGalleryItemShapeFill'
        end
        item
          ViewLevels = [ivlSmallIconWithText, ivlSmallIcon, ivlControlOnly]
          Visible = True
          ItemName = 'dxRibbonColorGalleryItemShapeOutline'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarArrange: TdxBar
      Caption = 'Arrange'
      CaptionButtons = <>
      DockedLeft = 169
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        6100000020744558745469746C65004272696E673B546F2046726F6E743B4672
        6F6E743B4F72646572020D7497000001E649444154785E7D913D6B944F14C57F
        77772D423E816813ACB5F005B4F20163912F112CAC04111B4B412B1B6BAB8865
        10414441FDFF4137A410226A61614014142D044121EEDBCCDC7B94DD671F7683
        E6C030CDCCB9BF736E8789ACB9E7254092F8973A80DDB8B5F1CC5A5649A23901
        EEA57BF5D2D93340EC65D02AEED595F3A79144CC4CBBFFE46D05EC33B3F2172A
        35063917B23BDBEB97E97F7D5353C001C4C6F593C3C6535014DDE56B5BCB8037
        1146A34CF160E7D32B4EAD5E00454DE2980245801C1474D76E5780CD4548A950
        4A10C5091FE13FDE230903844093D35EDC3F7E03B4E64A1C1B789053A03C405E
        EA3F02629A1ACF7D3C07BB096230E875EF3E78591DF240654894020814306364
        A31E6542D0363303D401F2DACDD51560F1E1C5C3DF63D4234A02A931514D60EA
        1325F87FF35DEFC5EB2FE3157724053034B3710F9EFAA8E47ABA9A0E24611178
        16C78F1C6473EB7305B43B34C2223B4A3D54128A6022D55B10D172A238BF0689
        51CA00366B8097C087039413128068F28B3199BB48C549A900B4660DA23FF4EE
        D33B1B154C8B83FA4280492C2C1DC3C36A8379827C6EFDC3CA74B54CB470EFD1
        D6B7134797F8B93302335AED36616D72D945302D931999597AFC7CBBFBDFE6C7
        2A2498C60A91D3A80B78873DD4ACB8A16AC8041420FD0621C0746CF11A9DD000
        00000049454E44AE426082}
      ItemLinks = <
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem11'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem10'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem12'
        end
        item
          ViewLevels = [ivlLargeControlOnly, ivlControlOnly]
          Visible = True
          ItemName = 'dxBarSubItem13'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarPrint: TdxBar
      Caption = 'Stampa'
      CaptionButtons = <>
      DockedLeft = 719
      DockedTop = 0
      FloatLeft = 652
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000000C744558745469746C65005072696E743BC83632EA00000267494441
        54785E7D93CB6B135114C6BF99C434A60F05698B1B5716752582E84AAD2822B6
        88B8101F50B45441210BEBC285150591A250A326462AA218F20FB810178A482C
        AD165AD0958216051F68D1966426F3B82FCFDCCC0C71512F7C73EE3DDCEF77EE
        DC87A19442D40C6AB74A332F4CD3EC05745E7FA33982F1CAF0E0D65D34E69127
        897F9B49EA3D7374A376AA901041F2E5D9ED0012A4A5019C0B28092C5A5E58D9
        808244476B0B38135111C4005AB55E7D587D191712928C147579052308908272
        5C03D2E4610064A0C0648E8E5776DF2EBF7D33385CB0BF7C7E0F2915494288C0
        28C0833E69EEE33B1C3E35FA67ECE1CCF4C5DCD33D0012C9E0B33CD3513EB477
        6DD744E54930D4D5852008240CD55807A3B1EB3AB0EC1A8EF4ADDF547A2C4B00
        D66880E0AAAB7B550675CB42329186904A5754A119000125015C38561DAB3B33
        604C75462B303D5F5042229D4AE0E78FEF3878EC4274046150210C686F4BE8B9
        9EC7D00460700832347000378B252C2C542145E0931AA1A4D23BBC72453B4E0F
        1D87C3380138026F03E032D409D2B3A107C5FC95C6A1C8F0084D8A8D0C744602
        B6CB41459B003E47CDE1A8D7194E666FE07FED5EFE2C7C9102F385E60600C3F7
        04AA1643D576B0BFBF0FD981CD284CCDEBCD6402641038BFA31BC5F22C7E2FDA
        A03F81CF1A0013009BFFF5753277E719EE8E3F070FCFDD63244E002E29070DE3
        D4B976BD8C91CB0FF0E9C3E46B10C708EF762BA985D43632F6722E7B628BDE79
        4087F846161E4DE3EAB99DEB0054490EC94E2AA54490085FA3655BD6ABDCFDA9
        6DF1B6A9F8ADC2756B1300BE91C75EEA31F9B94BFDFB00A44866EC44FCB23D92
        DB6CF80BF54A6944F3A08E160000000049454E44AE426082}
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPrintPreview'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton2'
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
    object dxBarManagerBar1: TdxBar
      Caption = 'Custom 1'
      CaptionButtons = <>
      DockedDockingStyle = dsNone
      DockedLeft = 93
      DockedTop = 0
      DockingStyle = dsNone
      FloatLeft = 1004
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSaveAs'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton1'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = False
      WholeRow = False
    end
    object dxBarManagerBarQuickAccess: TdxBar
      Caption = 'QuickAccess'
      CaptionButtons = <>
      DockedDockingStyle = dsNone
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsNone
      FloatLeft = 1004
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = False
      WholeRow = False
    end
    object dxBarManagerBar4: TdxBar
      Caption = 'File'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1004
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton6'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton12'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton19'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButton5'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBar7: TdxBar
      Caption = 'Chiudi'
      CaptionButtons = <>
      DockedLeft = 941
      DockedTop = 0
      FloatLeft = 1249
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton24'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object barDocumento: TdxBar
      Caption = 'Documento'
      CaptionButtons = <>
      DockedLeft = 250
      DockedTop = 0
      FloatLeft = 1004
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton4'
        end
        item
          Visible = True
          ItemName = 'btnDocFirma'
        end
        item
          Visible = True
          ItemName = 'btnDocProtocolla'
        end
        item
          Visible = True
          ItemName = 'btnDocConserva'
        end
        item
          Visible = True
          ItemName = 'btnDocInviaPec'
        end
        item
          Visible = True
          ItemName = 'btnDocInviaMail'
        end
        item
          Visible = True
          ItemName = 'btnDocAggiornaStato'
        end
        item
          Visible = True
          ItemName = 'btnDocVersioni'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object btnDocFirma: TdxBarLargeButton
      Action = actDocFirma
      Category = 0
    end
    object btnDocProtocolla: TdxBarLargeButton
      Action = actDocProtocolla
      Category = 0
    end
    object btnDocConserva: TdxBarLargeButton
      Action = actDocConserva
      Category = 0
    end
    object btnDocInviaPec: TdxBarLargeButton
      Action = actDocInviaPec
      Category = 0
    end
    object btnDocInviaMail: TdxBarLargeButton
      Action = actDocInviaMail
      Category = 0
    end
    object btnDocAggiornaStato: TdxBarLargeButton
      Action = actDocAggiornaStato
      Category = 0
    end
    object btnDocVersioni: TdxBarLargeButton
      Action = actDocVersioni
      Category = 0
    end
    object bccZoom: TdxBarControlContainerItem
      Caption = 'Zoom'
      Category = 0
      Hint = 'Zoom'
      Visible = ivAlways
      Control = tbZoom
    end
    object bsZoom: TdxBarStatic
      Caption = '100 %'
      Category = 0
      Hint = '100 %'
      Visible = ivAlways
    end
    object bbCursorLine: TdxBarButton
      Caption = 'Line: 0'
      Category = 0
      Hint = 'Line: 0'
      Visible = ivNever
    end
    object bbCursorColumn: TdxBarButton
      Caption = 'Column: 0'
      Category = 0
      Hint = 'Column: 0'
      Visible = ivNever
    end
    object bbLocked: TdxBarButton
      Caption = 'Locked'
      Category = 0
      Hint = 'Locked'
      Visible = ivNever
      ButtonStyle = bsChecked
    end
    object dxBarButton1: TdxBarButton
      Action = actPermessiAzione
      Category = 0
    end
    object dxBarLargeButton1: TdxBarLargeButton
      Action = actExportPDF
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = dxRichEditControlNewDocument
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = dxRichEditControlLoadDocument
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = dxRichEditControlShowAllFieldResults
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = dxRichEditControlShowInsertMergeFieldForm
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Action = dxRichEditControlShowAllFieldCodes
      Category = 0
    end
    object dxBarLargeButton2: TdxBarLargeButton
      Action = dxRichEditControlShowPrintForm
      Category = 0
    end
    object dxBarLargeButton3: TdxBarLargeButton
      Action = dxRichEditControlShowPageSetupForm
      Category = 0
    end
    object dxBarLargeButton12: TdxBarLargeButton
      Action = actSalvaConNome
      Category = 0
    end
    object dxBarLargeButton13: TdxBarLargeButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton2: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarLargeButton19: TdxBarLargeButton
      Action = actExportPDF
      Category = 0
    end
    object dxBarLargeButton24: TdxBarLargeButton
      Action = Chiudi
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
      ButtonStyle = bsChecked
      Down = True
    end
    object dxBarButton10: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
      ButtonStyle = bsChecked
    end
    object dxBarButton11: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
      ButtonStyle = bsChecked
    end
    object dxBarButton12: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarLargeButton5: TdxBarLargeButton
      Action = actShellExecute
      Category = 0
    end
    object dxBarLargeButton6: TdxBarLargeButton
      Action = actSalva
      Category = 0
    end
    object dxBarLargeButton4: TdxBarLargeButton
      Action = actDocGeneraAllegato
      Category = 0
    end
    object dxBarLargeButtonSaveAs: TdxBarLargeButton
      Action = dxRichEditControlSaveDocumentAs
      Category = 1
      SyncImageIndex = False
      ImageIndex = 223
    end
    object dxBarLargeButtonPaste: TdxBarLargeButton
      Action = dxRichEditControlPasteSelection
      Category = 2
      SyncImageIndex = False
      ImageIndex = 85
    end
    object dxBarButtonCut: TdxBarButton
      Action = dxRichEditControlCutSelection
      Category = 2
      LargeImageIndex = 65
    end
    object dxBarButtonCopy: TdxBarButton
      Action = dxRichEditControlCopySelection
      Category = 2
      LargeImageIndex = 62
    end
    object dxBarButtonSelectAll: TdxBarButton
      Action = dxRichEditControlSelectAll
      Category = 2
      LargeImageIndex = 193
    end
    object cxBarEditItemFont: TcxBarEditItem
      Action = dxRichEditControlChangeFontName
      Category = 3
      PropertiesClassName = 'TcxFontNameComboBoxProperties'
      Properties.FontPreview.Visible = False
      Properties.FontTypes = [cxftTTF]
    end
    object cxBarEditItemFontSize: TcxBarEditItem
      Action = dxRichEditControlChangeFontSize
      Category = 3
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
    object dxBarButtonGrowFont: TdxBarButton
      Action = dxRichEditControlIncreaseFontSize
      Category = 3
      LargeImageIndex = 332
    end
    object dxBarButtonShrinkFont: TdxBarButton
      Action = dxRichEditControlDecreaseFontSize
      Category = 3
      LargeImageIndex = 518
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'Change Case'
      Category = 3
      Visible = ivAlways
      ImageIndex = 326
      LargeImageIndex = 326
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonUPPERCASE'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonlowercase'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtontOGGLEcASE'
        end>
    end
    object dxBarLargeButtonUPPERCASE: TdxBarLargeButton
      Action = dxRichEditControlTextUpperCase
      Category = 3
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonlowercase: TdxBarLargeButton
      Action = dxRichEditControlTextLowerCase
      Category = 3
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtontOGGLEcASE: TdxBarLargeButton
      Action = dxRichEditControlToggleTextCase
      Category = 3
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarButtonBold: TdxBarButton
      Action = dxRichEditControlToggleFontBold
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 324
    end
    object dxBarButtonItalic: TdxBarButton
      Action = dxRichEditControlToggleFontItalic
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 339
    end
    object dxBarButtonUnderline: TdxBarButton
      Action = dxRichEditControlToggleFontUnderline
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 358
    end
    object dxBarButtonDoubleUnderline: TdxBarButton
      Action = dxRichEditControlToggleFontDoubleUnderline
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 359
    end
    object dxBarButtonStrikethrough: TdxBarButton
      Action = dxRichEditControlToggleFontStrikeout
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 347
    end
    object dxBarButtonDoubleStrikethrough: TdxBarButton
      Action = dxRichEditControlToggleFontDoubleStrikeout
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 348
    end
    object dxBarButtonSubscript: TdxBarButton
      Action = dxRichEditControlToggleFontSubscript
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 349
    end
    object dxBarButtonSuperscript: TdxBarButton
      Action = dxRichEditControlToggleFontSuperscript
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 350
    end
    object dxRibbonColorGalleryItemTextHighlightColor: TdxRibbonColorGalleryItem
      Action = dxRichEditControlTextHighlight
      Category = 3
      LargeImageIndex = 333
    end
    object dxRibbonColorGalleryItemFontColor: TdxRibbonColorGalleryItem
      Action = dxRichEditControlChangeFontColor
      Category = 3
      LargeImageIndex = 330
    end
    object dxBarButtonBullets: TdxBarButton
      Action = dxRichEditControlToggleBulletedList
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 343
    end
    object dxBarButtonNumbering: TdxBarButton
      Action = dxRichEditControlToggleSimpleNumberingList
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 345
    end
    object dxBarButtonMultilevellist: TdxBarButton
      Action = dxRichEditControlToggleMultiLevelList
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 344
    end
    object dxBarButtonDecreaseIndent: TdxBarButton
      Action = dxRichEditControlDecrementIndent
      Category = 4
      LargeImageIndex = 334
    end
    object dxBarButtonIncreaseIndent: TdxBarButton
      Action = dxRichEditControlIncrementIndent
      Category = 4
      LargeImageIndex = 336
    end
    object dxBarButtonShowHide: TdxBarButton
      Action = dxRichEditControlToggleShowWhitespace
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 450
    end
    object dxBarButtonAlignTextLeft: TdxBarButton
      Action = dxRichEditControlToggleParagraphAlignmentLeft
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 315
    end
    object dxBarButtonCenter: TdxBarButton
      Action = dxRichEditControlToggleParagraphAlignmentCenter
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 312
    end
    object dxBarButtonAlignTextRight: TdxBarButton
      Action = dxRichEditControlToggleParagraphAlignmentRight
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 319
    end
    object dxBarButtonJustify: TdxBarButton
      Action = dxRichEditControlToggleParagraphAlignmentJustify
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 314
    end
    object dxBarSubItem2: TdxBarSubItem
      Caption = 'Line Spacing'
      Category = 4
      Visible = ivAlways
      ImageIndex = 340
      LargeImageIndex = 340
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton10'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton15'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton20'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonParagraph'
        end>
    end
    object dxBarLargeButton10: TdxBarLargeButton
      Action = dxRichEditControlSetSingleParagraphSpacing
      Category = 4
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButton15: TdxBarLargeButton
      Action = dxRichEditControlSetSesquialteralParagraphSpacing
      Category = 4
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButton20: TdxBarLargeButton
      Action = dxRichEditControlSetDoubleParagraphSpacing
      Category = 4
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonParagraph: TdxBarLargeButton
      Action = dxRichEditControlShowParagraphForm
      Category = 4
      SyncImageIndex = False
      ImageIndex = 341
    end
    object dxRibbonGalleryItemQuickStyles: TdxRibbonGalleryItem
      Action = dxRichEditControlQuickStylesGallery
      Category = 5
      LargeImageIndex = 325
      GalleryOptions.ColumnCount = 4
      GalleryFilter.Categories = <>
      GalleryInMenuOptions.CollapsedInSubmenu = False
      GalleryInMenuOptions.DropDownGalleryResizing = gsrHeight
      GalleryInMenuOptions.ItemTextKind = itkNone
      ItemLinks = <>
      object dxRibbonGalleryItemQuickStylesGroup1: TdxRibbonGalleryGroup
      end
    end
    object dxBarButtonFind: TdxBarButton
      Action = dxRichEditControlSearchFind
      Category = 6
      LargeImageIndex = 189
    end
    object dxBarButtonReplace: TdxBarButton
      Action = dxRichEditControlSearchReplace
      Category = 6
      LargeImageIndex = 192
    end
    object dxBarLargeButtonUndo: TdxBarLargeButton
      Action = dxRichEditControlUndo
      Category = 6
      SyncImageIndex = False
      ImageIndex = 96
    end
    object dxBarLargeButtonRedo: TdxBarLargeButton
      Action = dxRichEditControlRedo
      Category = 6
      SyncImageIndex = False
      ImageIndex = 87
    end
    object dxBarLargeButtonPage: TdxBarLargeButton
      Action = dxRichEditControlInsertPageBreak
      Caption = 'Interruzione di pagina'
      Category = 7
      SyncImageIndex = False
      ImageIndex = 105
    end
    object dxBarLargeButtonTable: TdxBarLargeButton
      Action = dxRichEditControlShowInsertTableForm
      Category = 8
      SyncImageIndex = False
      ImageIndex = 234
    end
    object dxBarLargeButtonInlinePicture: TdxBarLargeButton
      Action = dxRichEditControlInsertPicture
      Category = 9
      SyncImageIndex = False
      ImageIndex = 419
    end
    object dxBarLargeButtonPicture: TdxBarLargeButton
      Action = dxRichEditControlInsertFloatingObjectPicture
      Category = 9
      SyncImageIndex = False
      ImageIndex = 419
    end
    object dxBarLargeButtonBookmark: TdxBarLargeButton
      Action = dxRichEditControlShowBookmarkForm
      Category = 10
      SyncImageIndex = False
      ImageIndex = 6
    end
    object dxBarLargeButtonHyperlink: TdxBarLargeButton
      Action = dxRichEditControlShowHyperlinkForm
      Category = 10
      SyncImageIndex = False
      ImageIndex = 525
    end
    object dxBarLargeButtonHeader: TdxBarLargeButton
      Action = dxRichEditControlEditPageHeader
      Category = 11
      SyncImageIndex = False
      ImageIndex = 291
    end
    object dxBarLargeButtonFooter: TdxBarLargeButton
      Action = dxRichEditControlEditPageFooter
      Category = 11
      SyncImageIndex = False
      ImageIndex = 290
    end
    object dxBarLargeButtonPageNumber: TdxBarLargeButton
      Action = dxRichEditControlInsertPageNumberField
      Category = 11
      SyncImageIndex = False
      ImageIndex = 107
    end
    object dxBarLargeButtonPageCount: TdxBarLargeButton
      Action = dxRichEditControlInsertPageCountField
      Category = 11
      SyncImageIndex = False
      ImageIndex = 106
    end
    object dxBarLargeButtonTextBox: TdxBarLargeButton
      Action = dxRichEditControlInsertTextBox
      Category = 12
      SyncImageIndex = False
      ImageIndex = 121
    end
    object dxBarLargeButtonSymbol: TdxBarLargeButton
      Action = dxRichEditControlShowSymbolForm
      Category = 13
      SyncImageIndex = False
      ImageIndex = 351
    end
    object dxRibbonGalleryItemMargins: TdxRibbonGalleryItem
      Action = dxRichEditControlPageMarginsGallery
      Category = 14
      LargeImageIndex = 294
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkCaptionAndDescription
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonCustomMargins'
        end>
      object dxRibbonGalleryItemMarginsGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemMarginsGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Normal'
          Description = 'Top:'#9'0,79 in    Bottom:'#9'0,79 in'#13#10'Left:'#9'1,18 in    Right:'#9'0,59 in'
          ImageIndex = 296
          ActionIndex = 0
        end
        object dxRibbonGalleryItemMarginsGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Narrow'
          Description = 'Top:'#9'0,50 in    Bottom:'#9'0,50 in'#13#10'Left:'#9'0,50 in    Right:'#9'0,50 in'
          ImageIndex = 295
          ActionIndex = 1
        end
        object dxRibbonGalleryItemMarginsGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Moderate'
          Description = 'Top:'#9'1,00 in    Bottom:'#9'1,00 in'#13#10'Left:'#9'0,75 in    Right:'#9'0,75 in'
          ImageIndex = 298
          ActionIndex = 2
        end
        object dxRibbonGalleryItemMarginsGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'Wide'
          Description = 'Top:'#9'1,00 in    Bottom:'#9'1,00 in'#13#10'Left:'#9'2,00 in    Right:'#9'2,00 in'
          ImageIndex = 300
          ActionIndex = 3
        end
      end
    end
    object dxBarLargeButtonCustomMargins: TdxBarLargeButton
      Action = dxRichEditControlShowPageMarginsSetupForm
      Category = 14
      LargeImageIndex = 294
      SyncImageIndex = False
      ImageIndex = 294
    end
    object dxBarSubItem3: TdxBarSubItem
      Caption = 'Orientamento'
      Category = 14
      Visible = ivAlways
      ImageIndex = 298
      LargeImageIndex = 298
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPortrait'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonLandscape'
        end>
    end
    object dxBarLargeButtonPortrait: TdxBarLargeButton
      Action = dxRichEditControlSetPortraitPageOrientation
      Category = 14
      ButtonStyle = bsChecked
      LargeImageIndex = 300
      SyncImageIndex = False
      ImageIndex = 300
    end
    object dxBarLargeButtonLandscape: TdxBarLargeButton
      Action = dxRichEditControlSetLandscapePageOrientation
      Category = 14
      ButtonStyle = bsChecked
      LargeImageIndex = 299
      SyncImageIndex = False
      ImageIndex = 299
    end
    object dxRibbonGalleryItemSize: TdxRibbonGalleryItem
      Action = dxRichEditControlPaperSizeGallery
      Category = 14
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
          ImageIndex = 269
          ActionIndex = 1
        end
        object dxRibbonGalleryItemSizeGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Tabloid'
          Description = '279,00 mm x 432,00 mm'
          ImageIndex = 268
          ActionIndex = 3
        end
        object dxRibbonGalleryItemSizeGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Legal'
          Description = '216,00 mm x 356,00 mm'
          ImageIndex = 266
          ActionIndex = 5
        end
        object dxRibbonGalleryItemSizeGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'Statement'
          Description = '140,00 mm x 216,00 mm'
          ImageIndex = 105
          ActionIndex = 6
        end
        object dxRibbonGalleryItemSizeGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'Executive'
          Description = '184,00 mm x 267,00 mm'
          ImageIndex = 99
          ActionIndex = 7
        end
        object dxRibbonGalleryItemSizeGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'A3'
          Description = '297,00 mm x 420,00 mm'
          ImageIndex = 110
          ActionIndex = 8
        end
        object dxRibbonGalleryItemSizeGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'A4'
          Description = '210,00 mm x 297,00 mm'
          ImageIndex = 109
          ActionIndex = 9
        end
        object dxRibbonGalleryItemSizeGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'A5'
          Description = '148,00 mm x 210,00 mm'
          ImageIndex = 111
          ActionIndex = 11
        end
        object dxRibbonGalleryItemSizeGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'B4'
          Description = '250,00 mm x 354,00 mm'
          ImageIndex = 386
          ActionIndex = 12
        end
        object dxRibbonGalleryItemSizeGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'B5'
          Description = '182,00 mm x 257,00 mm'
          ImageIndex = 415
          ActionIndex = 13
        end
      end
    end
    object dxBarLargeButtonMorePaperSizes: TdxBarLargeButton
      Action = dxRichEditControlShowPagePaperSetupForm
      Category = 14
      LargeImageIndex = 306
      SyncImageIndex = False
      ImageIndex = 306
    end
    object dxBarSubItem4: TdxBarSubItem
      Caption = 'Colonne'
      Category = 14
      Visible = ivAlways
      ImageIndex = 269
      LargeImageIndex = 269
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonOne'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTwo'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonThree'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonMoreColumns'
        end>
    end
    object dxBarLargeButtonOne: TdxBarLargeButton
      Action = dxRichEditControlSetSectionOneColumn
      Category = 14
      ButtonStyle = bsChecked
      LargeImageIndex = 267
      SyncImageIndex = False
      ImageIndex = 267
    end
    object dxBarLargeButtonTwo: TdxBarLargeButton
      Action = dxRichEditControlSetSectionTwoColumns
      Category = 14
      ButtonStyle = bsChecked
      LargeImageIndex = 269
      SyncImageIndex = False
      ImageIndex = 269
    end
    object dxBarLargeButtonThree: TdxBarLargeButton
      Action = dxRichEditControlSetSectionThreeColumns
      Category = 14
      ButtonStyle = bsChecked
      LargeImageIndex = 268
      SyncImageIndex = False
      ImageIndex = 268
    end
    object dxBarLargeButtonMoreColumns: TdxBarLargeButton
      Action = dxRichEditControlShowColumnsSetupForm
      Category = 14
      LargeImageIndex = 266
      SyncImageIndex = False
      ImageIndex = 266
    end
    object dxBarSubItem5: TdxBarSubItem
      Caption = 'Interruzioni'
      Category = 14
      Visible = ivAlways
      ImageIndex = 105
      LargeImageIndex = 105
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonPage'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonColumn'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSectionNextPage'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSectionEvenPage'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSectionOddPage'
        end>
    end
    object dxBarLargeButtonColumn: TdxBarLargeButton
      Action = dxRichEditControlInsertColumnBreak
      Category = 14
      LargeImageIndex = 99
      SyncImageIndex = False
      ImageIndex = 99
    end
    object dxBarLargeButtonSectionNextPage: TdxBarLargeButton
      Action = dxRichEditControlInsertSectionBreakNextPage
      Category = 14
      LargeImageIndex = 110
      SyncImageIndex = False
      ImageIndex = 110
    end
    object dxBarLargeButtonSectionEvenPage: TdxBarLargeButton
      Action = dxRichEditControlInsertSectionBreakEvenPage
      Category = 14
      LargeImageIndex = 109
      SyncImageIndex = False
      ImageIndex = 109
    end
    object dxBarLargeButtonSectionOddPage: TdxBarLargeButton
      Action = dxRichEditControlInsertSectionBreakOddPage
      Category = 14
      LargeImageIndex = 111
      SyncImageIndex = False
      ImageIndex = 111
    end
    object dxBarSubItem6: TdxBarSubItem
      Caption = 'Numeri di riga'
      Category = 14
      Visible = ivAlways
      ImageIndex = 386
      LargeImageIndex = 386
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonNone'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonContinuous'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonRestartEachPage'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonRestartEachSection'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarLargeButtonLineNumberingOptions'
        end>
    end
    object dxBarLargeButtonNone: TdxBarLargeButton
      Action = dxRichEditControlSetSectionLineNumberingNone
      Category = 14
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonContinuous: TdxBarLargeButton
      Action = dxRichEditControlSetSectionLineNumberingContinuous
      Category = 14
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonRestartEachPage: TdxBarLargeButton
      Action = dxRichEditControlSetSectionLineNumberingRestartNewPage
      Category = 14
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonRestartEachSection: TdxBarLargeButton
      Action = dxRichEditControlSetSectionLineNumberingRestartNewSection
      Category = 14
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLineNumberingOptions: TdxBarLargeButton
      Action = dxRichEditControlShowLineNumberingForm
      Category = 14
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxRibbonColorGalleryItemPageColor: TdxRibbonColorGalleryItem
      Action = dxRichEditControlChangePageColor
      Category = 15
      LargeImageIndex = 415
    end
    object dxBarLargeButtonTableofContents: TdxBarLargeButton
      Action = dxRichEditControlInsertTableOfContents
      Category = 16
      SyncImageIndex = False
      ImageIndex = 116
    end
    object dxBarLargeButtonUpdateTable: TdxBarLargeButton
      Action = dxRichEditControlUpdateTableOfContents
      Category = 16
      SyncImageIndex = False
      ImageIndex = 177
    end
    object dxBarLargeButtonAddText: TdxBarLargeButton
      Action = dxRichEditControlAddParagraphsToTableOfContentsPlaceholder
      Category = 16
      ButtonStyle = bsDropDown
      DropDownMenu = dxRibbonPopupMenu1
      SyncImageIndex = False
      ImageIndex = 51
    end
    object dxBarLargeButtonDoNotShowinTableofContents: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphBodyTextLevel
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel1: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading1Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel2: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading2Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel3: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading3Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel4: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading4Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel5: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading5Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel6: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading6Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel7: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading7Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel8: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading8Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonLevel9: TdxBarLargeButton
      Action = dxRichEditControlTableOfContentsSetParagraphHeading9Level
      Category = 16
      SyncImageIndex = False
      ImageIndex = -1
    end
    object dxBarLargeButtonInsertCaption: TdxBarLargeButton
      Action = dxRichEditControlInsertCaptionPlaceholder
      Category = 17
      ButtonStyle = bsDropDown
      DropDownMenu = dxRibbonPopupMenu2
      SyncImageIndex = False
      ImageIndex = 97
    end
    object dxBarLargeButtonFiguresCaption: TdxBarLargeButton
      Action = dxRichEditControlInsertFigureCaption
      Category = 17
      LargeImageIndex = 104
      SyncImageIndex = False
      ImageIndex = 104
    end
    object dxBarLargeButtonTablesCaption: TdxBarLargeButton
      Action = dxRichEditControlInsertTableCaption
      Category = 17
      LargeImageIndex = 112
      SyncImageIndex = False
      ImageIndex = 112
    end
    object dxBarLargeButtonEquationsCaption: TdxBarLargeButton
      Action = dxRichEditControlInsertEquationCaption
      Category = 17
      LargeImageIndex = 103
      SyncImageIndex = False
      ImageIndex = 103
    end
    object dxBarLargeButtonInsertTableofFigures: TdxBarLargeButton
      Action = dxRichEditControlInsertTableOfFiguresPlaceholder
      Category = 17
      ButtonStyle = bsDropDown
      DropDownMenu = dxRibbonPopupMenu3
      SyncImageIndex = False
      ImageIndex = 115
    end
    object dxBarLargeButtonTableofFigures: TdxBarLargeButton
      Action = dxRichEditControlInsertTableOfFigures
      Category = 17
      LargeImageIndex = 118
      SyncImageIndex = False
      ImageIndex = 118
    end
    object dxBarLargeButtonTableofTables: TdxBarLargeButton
      Action = dxRichEditControlInsertTableOfTables
      Category = 17
      LargeImageIndex = 112
      SyncImageIndex = False
      ImageIndex = 112
    end
    object dxBarLargeButtonTableofEquations: TdxBarLargeButton
      Action = dxRichEditControlInsertTableOfEquations
      Category = 17
      LargeImageIndex = 117
      SyncImageIndex = False
      ImageIndex = 117
    end
    object dxBarLargeButtonUpdateTable1: TdxBarLargeButton
      Action = dxRichEditControlUpdateTableOfFigures
      Category = 17
      SyncImageIndex = False
      ImageIndex = 177
    end
    object dxBarLargeButtonViewMergedData: TdxBarLargeButton
      Action = dxRichEditControlToggleViewMergedData
      Category = 18
      LargeImageIndex = 455
      SyncImageIndex = False
      ImageIndex = 455
    end
    object dxBarLargeButtonSpelling: TdxBarLargeButton
      Action = dxRichEditControlCheckSpelling
      Category = 19
      SyncImageIndex = False
      ImageIndex = 94
    end
    object dxBarLargeButtonProtectDocument: TdxBarLargeButton
      Action = dxRichEditControlProtectDocument
      Category = 20
      SyncImageIndex = False
      ImageIndex = 493
    end
    object dxBarLargeButtonUnprotectDocument: TdxBarLargeButton
      Action = dxRichEditControlUnprotectDocument
      Category = 20
      SyncImageIndex = False
      ImageIndex = 31
    end
    object dxBarLargeButtonRangeEditingPermissions: TdxBarLargeButton
      Action = dxRichEditControlShowRangeEditingPermissions
      Category = 20
      SyncImageIndex = False
      ImageIndex = 81
    end
    object dxBarLargeButtonEncryptwithPassword: TdxBarLargeButton
      Action = dxRichEditControlEncryptDocument
      Category = 20
      SyncImageIndex = False
      ImageIndex = 492
    end
    object dxBarLargeButtonSimpleView: TdxBarLargeButton
      Action = dxRichEditControlSwitchToSimpleView
      Category = 21
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = 453
    end
    object dxBarLargeButtonDraftView: TdxBarLargeButton
      Action = dxRichEditControlSwitchToDraftView
      Category = 21
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = 439
    end
    object dxBarLargeButtonPrintLayout: TdxBarLargeButton
      Action = dxRichEditControlSwitchToPrintLayoutView
      Category = 21
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = 210
    end
    object dxBarLargeButtonHorizontalRuler: TdxBarLargeButton
      Action = dxRichEditControlToggleShowHorizontalRuler
      Category = 22
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = 445
    end
    object dxBarLargeButtonVerticalRuler: TdxBarLargeButton
      Action = dxRichEditControlToggleShowVerticalRuler
      Category = 22
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = 446
    end
    object dxBarLargeButtonZoomOut: TdxBarLargeButton
      Action = dxRichEditControlZoomOut
      Category = 23
      SyncImageIndex = False
      ImageIndex = 460
    end
    object dxBarLargeButtonZoomIn: TdxBarLargeButton
      Action = dxRichEditControlZoomIn
      Category = 23
      SyncImageIndex = False
      ImageIndex = 459
    end
    object dxBarLargeButtonGotoHeader: TdxBarLargeButton
      Action = dxRichEditControlGoToPageHeader
      Category = 24
      SyncImageIndex = False
      ImageIndex = 291
    end
    object dxBarLargeButtonGotoFooter: TdxBarLargeButton
      Action = dxRichEditControlGoToPageFooter
      Category = 24
      SyncImageIndex = False
      ImageIndex = 290
    end
    object dxBarLargeButtonShowNext: TdxBarLargeButton
      Action = dxRichEditControlGoToNextPageHeaderFooter
      Category = 24
      SyncImageIndex = False
      ImageIndex = 150
    end
    object dxBarLargeButtonShowPrevious: TdxBarLargeButton
      Action = dxRichEditControlGoToPreviousPageHeaderFooter
      Category = 24
      SyncImageIndex = False
      ImageIndex = 151
    end
    object dxBarLargeButtonLinktoPrevious: TdxBarLargeButton
      Action = dxRichEditControlToggleHeaderFooterLinkToPrevious
      Category = 24
      SyncImageIndex = False
      ImageIndex = 158
    end
    object dxBarLargeButtonDifferentFirstPage: TdxBarLargeButton
      Action = dxRichEditControlToggleDifferentFirstPage
      Category = 25
      SyncImageIndex = False
      ImageIndex = 7
    end
    object dxBarLargeButtonDifferentOddEvenPages: TdxBarLargeButton
      Action = dxRichEditControlToggleDifferentOddAndEvenPages
      Category = 25
      SyncImageIndex = False
      ImageIndex = 8
    end
    object dxBarLargeButtonCloseHeaderandFooter: TdxBarLargeButton
      Action = dxRichEditControlClosePageHeaderFooter
      Category = 26
      SyncImageIndex = False
      ImageIndex = 60
    end
    object dxBarLargeButtonViewGridlines: TdxBarLargeButton
      Action = dxRichEditControlToggleShowTableGridLines
      Category = 27
      ButtonStyle = bsChecked
      SyncImageIndex = False
      ImageIndex = 456
    end
    object dxBarLargeButtonTableProperties: TdxBarLargeButton
      Action = dxRichEditControlShowTablePropertiesForm
      Category = 27
      SyncImageIndex = False
      ImageIndex = 287
    end
    object dxBarSubItem7: TdxBarSubItem
      Caption = 'Elimina'
      Category = 28
      Visible = ivAlways
      ImageIndex = 73
      LargeImageIndex = 73
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteCells'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteColumns'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteRows'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonDeleteTable'
        end>
    end
    object dxBarLargeButtonDeleteCells: TdxBarLargeButton
      Action = dxRichEditControlShowDeleteTableCellsForm
      Category = 28
      LargeImageIndex = 74
      SyncImageIndex = False
      ImageIndex = 74
    end
    object dxBarLargeButtonDeleteColumns: TdxBarLargeButton
      Action = dxRichEditControlDeleteTableColumns
      Category = 28
      LargeImageIndex = 75
      SyncImageIndex = False
      ImageIndex = 75
    end
    object dxBarLargeButtonDeleteRows: TdxBarLargeButton
      Action = dxRichEditControlDeleteTableRows
      Category = 28
      LargeImageIndex = 76
      SyncImageIndex = False
      ImageIndex = 76
    end
    object dxBarLargeButtonDeleteTable: TdxBarLargeButton
      Action = dxRichEditControlDeleteTable
      Category = 28
      LargeImageIndex = 73
      SyncImageIndex = False
      ImageIndex = 73
    end
    object dxBarLargeButtonInsertAbove: TdxBarLargeButton
      Action = dxRichEditControlInsertTableRowAbove
      Category = 28
      SyncImageIndex = False
      ImageIndex = 119
    end
    object dxBarLargeButtonInsertBelow: TdxBarLargeButton
      Action = dxRichEditControlInsertTableRowBelow
      Category = 28
      SyncImageIndex = False
      ImageIndex = 120
    end
    object dxBarLargeButtonInsertLeft: TdxBarLargeButton
      Action = dxRichEditControlInsertTableColumnToTheLeft
      Category = 28
      SyncImageIndex = False
      ImageIndex = 113
    end
    object dxBarLargeButtonInsertRight: TdxBarLargeButton
      Action = dxRichEditControlInsertTableColumnToTheRight
      Category = 28
      SyncImageIndex = False
      ImageIndex = 114
    end
    object dxBarLargeButtonMergeCells: TdxBarLargeButton
      Action = dxRichEditControlMergeTableCells
      Category = 29
      SyncImageIndex = False
      ImageIndex = 275
    end
    object dxBarLargeButtonSplitCells: TdxBarLargeButton
      Action = dxRichEditControlShowSplitTableCellsForm
      Category = 29
      SyncImageIndex = False
      ImageIndex = 280
    end
    object dxBarLargeButtonSplitTable: TdxBarLargeButton
      Action = dxRichEditControlSplitTable
      Category = 29
      SyncImageIndex = False
      ImageIndex = 279
    end
    object dxBarSubItem8: TdxBarSubItem
      Caption = 'Adatta'
      Category = 30
      Visible = ivAlways
      ImageIndex = 285
      LargeImageIndex = 285
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonAutoFitContents'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonAutoFitWindow'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonFixedColumnWidth'
        end>
    end
    object dxBarLargeButtonAutoFitContents: TdxBarLargeButton
      Action = dxRichEditControlToggleTableAutoFitContents
      Category = 30
      LargeImageIndex = 285
      SyncImageIndex = False
      ImageIndex = 285
    end
    object dxBarLargeButtonAutoFitWindow: TdxBarLargeButton
      Action = dxRichEditControlToggleTableAutoFitWindow
      Category = 30
      LargeImageIndex = 286
      SyncImageIndex = False
      ImageIndex = 286
    end
    object dxBarLargeButtonFixedColumnWidth: TdxBarLargeButton
      Action = dxRichEditControlToggleTableFixedColumnWidth
      Category = 30
      LargeImageIndex = 236
      SyncImageIndex = False
      ImageIndex = 236
    end
    object dxBarButtonAlignTopLeft: TdxBarButton
      Action = dxRichEditControlToggleTableCellsTopLeftAlignment
      Category = 31
      LargeImageIndex = 321
    end
    object dxBarButtonAlignTopCenter: TdxBarButton
      Action = dxRichEditControlToggleTableCellsTopCenterAlignment
      Category = 31
      LargeImageIndex = 320
    end
    object dxBarButtonAlignTopRight: TdxBarButton
      Action = dxRichEditControlToggleTableCellsTopRightAlignment
      Category = 31
      LargeImageIndex = 322
    end
    object dxBarButtonAlignCenterLeft: TdxBarButton
      Action = dxRichEditControlToggleTableCellsMiddleLeftAlignment
      Category = 31
      LargeImageIndex = 317
    end
    object dxBarButtonAlignCenter: TdxBarButton
      Action = dxRichEditControlToggleTableCellsMiddleCenterAlignment
      Category = 31
      LargeImageIndex = 316
    end
    object dxBarButtonAlignCenterRight: TdxBarButton
      Action = dxRichEditControlToggleTableCellsMiddleRightAlignment
      Category = 31
      LargeImageIndex = 318
    end
    object dxBarButtonAlignBottomLeft: TdxBarButton
      Action = dxRichEditControlToggleTableCellsBottomLeftAlignment
      Category = 31
      LargeImageIndex = 310
    end
    object dxBarButtonAlignBottomCenter: TdxBarButton
      Action = dxRichEditControlToggleTableCellsBottomCenterAlignment
      Category = 31
      LargeImageIndex = 309
    end
    object dxBarButtonAlignBottomRight: TdxBarButton
      Action = dxRichEditControlToggleTableCellsBottomRightAlignment
      Category = 31
      LargeImageIndex = 311
    end
    object dxRibbonGalleryItemTableStyles: TdxRibbonGalleryItem
      Action = dxRichEditControlTableStylesGallery
      Category = 32
      LargeImageIndex = 26
      GalleryOptions.ColumnCount = 7
      GalleryFilter.Categories = <>
      GalleryInMenuOptions.CollapsedInSubmenu = False
      GalleryInMenuOptions.DropDownGalleryResizing = gsrHeight
      GalleryInMenuOptions.ItemTextKind = itkNone
      ItemLinks = <>
      object dxRibbonGalleryItemTableStylesGroup1: TdxRibbonGalleryGroup
      end
    end
    object dxBarSubItem9: TdxBarSubItem
      Caption = 'Bordi'
      Category = 32
      Visible = ivAlways
      ImageIndex = 259
      LargeImageIndex = 259
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
          ItemName = 'dxBarLargeButtonInsideBorders'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsideHorizontalBorder'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInsideVerticalBorder'
        end>
    end
    object dxBarLargeButtonBottomBorder: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsBottomBorder
      Category = 32
      LargeImageIndex = 250
      SyncImageIndex = False
      ImageIndex = 250
    end
    object dxBarLargeButtonTopBorder: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsTopBorder
      Category = 32
      LargeImageIndex = 261
      SyncImageIndex = False
      ImageIndex = 261
    end
    object dxBarLargeButtonLeftBorder: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsLeftBorder
      Category = 32
      LargeImageIndex = 255
      SyncImageIndex = False
      ImageIndex = 255
    end
    object dxBarLargeButtonRightBorder: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsRightBorder
      Category = 32
      LargeImageIndex = 257
      SyncImageIndex = False
      ImageIndex = 257
    end
    object dxBarLargeButtonNoBorder: TdxBarLargeButton
      Action = dxRichEditControlResetTableCellsBorders
      Category = 32
      LargeImageIndex = 256
      SyncImageIndex = False
      ImageIndex = 256
    end
    object dxBarLargeButtonAllBorders: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsAllBorders
      Category = 32
      LargeImageIndex = 248
      SyncImageIndex = False
      ImageIndex = 248
    end
    object dxBarLargeButtonOutsideBorders: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsOutsideBorder
      Category = 32
      LargeImageIndex = 259
      SyncImageIndex = False
      ImageIndex = 259
    end
    object dxBarLargeButtonInsideBorders: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsInsideBorder
      Category = 32
      LargeImageIndex = 258
      SyncImageIndex = False
      ImageIndex = 258
    end
    object dxBarLargeButtonInsideHorizontalBorder: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsInsideHorizontalBorder
      Category = 32
      LargeImageIndex = 253
      SyncImageIndex = False
      ImageIndex = 253
    end
    object dxBarLargeButtonInsideVerticalBorder: TdxBarLargeButton
      Action = dxRichEditControlToggleTableCellsInsideVerticalBorder
      Category = 32
      LargeImageIndex = 254
      SyncImageIndex = False
      ImageIndex = 254
    end
    object dxRibbonColorGalleryItemShapeFill: TdxRibbonColorGalleryItem
      Action = dxRichEditControlChangeFloatingObjectFillColor
      Category = 33
      LargeImageIndex = 416
    end
    object dxRibbonColorGalleryItemShapeOutline: TdxRibbonColorGalleryItem
      Action = dxRichEditControlChangeFloatingObjectOutlineColor
      Category = 33
      LargeImageIndex = 417
    end
    object dxBarSubItem10: TdxBarSubItem
      Caption = 'Testo a capo'
      Category = 34
      Visible = ivAlways
      ImageIndex = 432
      LargeImageIndex = 432
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSquare'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTight'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonThrough'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopandBottom'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBehindText'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonInFrontofText'
        end>
    end
    object dxBarLargeButtonSquare: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectSquareTextWrapType
      Category = 34
      LargeImageIndex = 507
      SyncImageIndex = False
      ImageIndex = 507
    end
    object dxBarLargeButtonTight: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectTightTextWrapType
      Category = 34
      LargeImageIndex = 432
      SyncImageIndex = False
      ImageIndex = 432
    end
    object dxBarLargeButtonThrough: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectThroughTextWrapType
      Category = 34
      LargeImageIndex = 431
      SyncImageIndex = False
      ImageIndex = 431
    end
    object dxBarLargeButtonTopandBottom: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectTopAndBottomTextWrapType
      Category = 34
      LargeImageIndex = 393
      SyncImageIndex = False
      ImageIndex = 393
    end
    object dxBarLargeButtonBehindText: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectBehindTextWrapType
      Category = 34
      LargeImageIndex = 323
      SyncImageIndex = False
      ImageIndex = 323
    end
    object dxBarLargeButtonInFrontofText: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectInFrontOfTextWrapType
      Category = 34
      LargeImageIndex = 338
      SyncImageIndex = False
      ImageIndex = 338
    end
    object dxBarSubItem11: TdxBarSubItem
      Caption = 'Posizione'
      Category = 34
      Visible = ivAlways
      ImageIndex = 397
      LargeImageIndex = 397
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopLeft'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopCenter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonTopRight'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMiddleLeft'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMiddleCenter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonMiddleRight'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBottomLeft'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBottomCenter'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBottomRight'
        end>
    end
    object dxBarLargeButtonTopLeft: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectTopLeftAlignment
      Category = 34
      LargeImageIndex = 396
      SyncImageIndex = False
      ImageIndex = 396
    end
    object dxBarLargeButtonTopCenter: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectTopCenterAlignment
      Category = 34
      LargeImageIndex = 395
      SyncImageIndex = False
      ImageIndex = 395
    end
    object dxBarLargeButtonTopRight: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectTopRightAlignment
      Category = 34
      LargeImageIndex = 397
      SyncImageIndex = False
      ImageIndex = 397
    end
    object dxBarLargeButtonMiddleLeft: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectMiddleLeftAlignment
      Category = 34
      LargeImageIndex = 182
      SyncImageIndex = False
      ImageIndex = 182
    end
    object dxBarLargeButtonMiddleCenter: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectMiddleCenterAlignment
      Category = 34
      LargeImageIndex = 361
      SyncImageIndex = False
      ImageIndex = 361
    end
    object dxBarLargeButtonMiddleRight: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectMiddleRightAlignment
      Category = 34
      LargeImageIndex = 183
      SyncImageIndex = False
      ImageIndex = 183
    end
    object dxBarLargeButtonBottomLeft: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectBottomLeftAlignment
      Category = 34
      LargeImageIndex = 180
      SyncImageIndex = False
      ImageIndex = 180
    end
    object dxBarLargeButtonBottomCenter: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectBottomCenterAlignment
      Category = 34
      LargeImageIndex = 360
      SyncImageIndex = False
      ImageIndex = 360
    end
    object dxBarLargeButtonBottomRight: TdxBarLargeButton
      Action = dxRichEditControlSetFloatingObjectBottomRightAlignment
      Category = 34
      LargeImageIndex = 181
      SyncImageIndex = False
      ImageIndex = 181
    end
    object dxBarSubItem12: TdxBarSubItem
      Caption = 'Porta avandi'
      Category = 34
      Visible = ivAlways
      ImageIndex = 411
      LargeImageIndex = 411
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBringForward'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBringtoFront'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonBringinFrontofText'
        end>
    end
    object dxBarLargeButtonBringForward: TdxBarLargeButton
      Action = dxRichEditControlFloatingObjectBringForward
      Category = 34
      LargeImageIndex = 411
      SyncImageIndex = False
      ImageIndex = 411
    end
    object dxBarLargeButtonBringtoFront: TdxBarLargeButton
      Action = dxRichEditControlFloatingObjectBringToFront
      Category = 34
      LargeImageIndex = 412
      SyncImageIndex = False
      ImageIndex = 412
    end
    object dxBarLargeButtonBringinFrontofText: TdxBarLargeButton
      Action = dxRichEditControlFloatingObjectBringInFrontOfText
      Category = 34
      LargeImageIndex = 413
      SyncImageIndex = False
      ImageIndex = 413
    end
    object dxBarSubItem13: TdxBarSubItem
      Caption = 'Porta indietro'
      Category = 34
      Visible = ivAlways
      ImageIndex = 429
      LargeImageIndex = 429
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSendBackward'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSendtoBack'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButtonSendBehindText'
        end>
    end
    object dxBarLargeButtonSendBackward: TdxBarLargeButton
      Action = dxRichEditControlFloatingObjectSendBackward
      Category = 34
      LargeImageIndex = 429
      SyncImageIndex = False
      ImageIndex = 429
    end
    object dxBarLargeButtonSendtoBack: TdxBarLargeButton
      Action = dxRichEditControlFloatingObjectSendToBack
      Category = 34
      LargeImageIndex = 430
      SyncImageIndex = False
      ImageIndex = 430
    end
    object dxBarLargeButtonSendBehindText: TdxBarLargeButton
      Action = dxRichEditControlFloatingObjectSendBehindText
      Category = 34
      LargeImageIndex = 468
      SyncImageIndex = False
      ImageIndex = 468
    end
    object dxBarLargeButtonPrintPreview: TdxBarLargeButton
      Action = dxRichEditControlShowPrintPreviewForm
      Category = 35
      SyncImageIndex = False
      ImageIndex = 169
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 112
    Top = 176
    object dxRichEditControlNewDocument: TdxRichEditControlNewDocument
      Category = 'DevExpress RichEdit Control.File.Common'
      Caption = 'Nuovo Template'
      ImageIndex = 1
      AssignedValues.Caption = True
    end
    object actSalva: TAction
      Caption = 'Salva'
      ImageIndex = 92
      OnExecute = actSalvaExecute
      OnUpdate = actSalvaUpdate
    end
    object actSalvaConNome: TAction
      Caption = 'Salva con nome'
      ImageIndex = 223
      OnExecute = actSalvaConNomeExecute
    end
    object actDocGeneraAllegato: TAction
      Caption = 'Genera Allegato'
      ImageIndex = 540
      OnExecute = actDocGeneraAllegatoExecute
      OnUpdate = actDocGeneraAllegatoUpdate
    end
    object actDocFirma: TAction
      Caption = 'Firma'
      ImageIndex = 531
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocProtocolla: TAction
      Caption = 'Protocolla'
      ImageIndex = 12
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocConserva: TAction
      Caption = 'Conserva'
      ImageIndex = 10
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocInviaPec: TAction
      Caption = 'Invia PEC'
      ImageIndex = 467
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocInviaMail: TAction
      Caption = 'Invia Mail'
      ImageIndex = 461
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocAggiornaStato: TAction
      Caption = 'Aggiorna stato'
      ImageIndex = 89
      OnExecute = AggiornaStatoDocumentoExecute
      OnUpdate = AggiornaStatoDocumentoUpdate
    end
    object actDocVersioni: TAction
      Caption = 'Versioni'
      ImageIndex = 14
      OnExecute = VersioniDocumentoExecute
      OnUpdate = VersioniDocumentoUpdate
    end
    object dxRichEditControlLoadDocument: TdxRichEditControlLoadDocument
      Category = 'DevExpress RichEdit Control.File.Common'
      Caption = 'Carica Template'
      ImageIndex = 36
      AssignedValues.Caption = True
    end
    object dxRichEditControlSaveDocumentAs: TdxRichEditControlSaveDocumentAs
      Category = 'DevExpress RichEdit Control.File.Common'
      ImageIndex = 223
    end
    object dxRichEditControlPasteSelection: TdxRichEditControlPasteSelection
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      Caption = 'Incolla'
      ImageIndex = 85
      AssignedValues.Caption = True
    end
    object dxRichEditControlCutSelection: TdxRichEditControlCutSelection
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      Caption = 'Taglia'
      ImageIndex = 65
      AssignedValues.Caption = True
    end
    object dxRichEditControlCopySelection: TdxRichEditControlCopySelection
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      Caption = 'Copia'
      ImageIndex = 62
      AssignedValues.Caption = True
    end
    object dxRichEditControlSelectAll: TdxRichEditControlSelectAll
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      Caption = 'Seleziona tutto'
      ImageIndex = 193
      AssignedValues.Caption = True
    end
    object dxRichEditControlChangeFontName: TdxRichEditControlChangeFontName
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 325
    end
    object dxRichEditControlChangeFontSize: TdxRichEditControlChangeFontSize
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 331
    end
    object actShellExecute: TAction
      Caption = 'Editor sistema'
      ImageIndex = 37
      OnExecute = actShellExecuteExecute
    end
    object dxRichEditControlIncreaseFontSize: TdxRichEditControlIncreaseFontSize
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 332
    end
    object dxRichEditControlDecreaseFontSize: TdxRichEditControlDecreaseFontSize
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 518
    end
    object dxRichEditControlTextUpperCase: TdxRichEditControlTextUpperCase
      Category = 'DevExpress RichEdit Control.Home.Font'
    end
    object dxRichEditControlTextLowerCase: TdxRichEditControlTextLowerCase
      Category = 'DevExpress RichEdit Control.Home.Font'
    end
    object dxRichEditControlToggleTextCase: TdxRichEditControlToggleTextCase
      Category = 'DevExpress RichEdit Control.Home.Font'
    end
    object dxRichEditControlToggleFontBold: TdxRichEditControlToggleFontBold
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 324
    end
    object dxRichEditControlToggleFontItalic: TdxRichEditControlToggleFontItalic
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 339
    end
    object dxRichEditControlToggleFontUnderline: TdxRichEditControlToggleFontUnderline
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 358
    end
    object dxRichEditControlToggleFontDoubleUnderline: TdxRichEditControlToggleFontDoubleUnderline
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 359
    end
    object dxRichEditControlToggleFontStrikeout: TdxRichEditControlToggleFontStrikeout
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 347
    end
    object dxRichEditControlToggleFontDoubleStrikeout: TdxRichEditControlToggleFontDoubleStrikeout
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 348
    end
    object dxRichEditControlToggleFontSubscript: TdxRichEditControlToggleFontSubscript
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 349
    end
    object dxRichEditControlToggleFontSuperscript: TdxRichEditControlToggleFontSuperscript
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 350
    end
    object dxRichEditControlTextHighlight: TdxRichEditControlTextHighlight
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 333
    end
    object dxRichEditControlChangeFontColor: TdxRichEditControlChangeFontColor
      Category = 'DevExpress RichEdit Control.Home.Font'
      ImageIndex = 330
    end
    object dxRichEditControlToggleBulletedList: TdxRichEditControlToggleBulletedList
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 343
    end
    object dxRichEditControlToggleSimpleNumberingList: TdxRichEditControlToggleSimpleNumberingList
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 345
    end
    object dxRichEditControlToggleMultiLevelList: TdxRichEditControlToggleMultiLevelList
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 344
    end
    object dxRichEditControlDecrementIndent: TdxRichEditControlDecrementIndent
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 334
    end
    object dxRichEditControlIncrementIndent: TdxRichEditControlIncrementIndent
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 336
    end
    object dxRichEditControlToggleShowWhitespace: TdxRichEditControlToggleShowWhitespace
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 450
    end
    object dxRichEditControlToggleParagraphAlignmentLeft: TdxRichEditControlToggleParagraphAlignmentLeft
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 315
    end
    object dxRichEditControlToggleParagraphAlignmentCenter: TdxRichEditControlToggleParagraphAlignmentCenter
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 312
    end
    object dxRichEditControlToggleParagraphAlignmentRight: TdxRichEditControlToggleParagraphAlignmentRight
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 319
    end
    object dxRichEditControlToggleParagraphAlignmentJustify: TdxRichEditControlToggleParagraphAlignmentJustify
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 314
    end
    object dxRichEditControlSetSingleParagraphSpacing: TdxRichEditControlSetSingleParagraphSpacing
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
    end
    object dxRichEditControlSetSesquialteralParagraphSpacing: TdxRichEditControlSetSesquialteralParagraphSpacing
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
    end
    object dxRichEditControlSetDoubleParagraphSpacing: TdxRichEditControlSetDoubleParagraphSpacing
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
    end
    object dxRichEditControlShowParagraphForm: TdxRichEditControlShowParagraphForm
      Category = 'DevExpress RichEdit Control.Home.Paragraph'
      ImageIndex = 341
    end
    object dxRichEditControlQuickStylesGallery: TdxRichEditControlQuickStylesGallery
      Category = 'DevExpress RichEdit Control.Home.Styles'
      ImageIndex = 325
      GalleryGroup = dxRibbonGalleryItemQuickStylesGroup1
    end
    object dxRichEditControlSearchFind: TdxRichEditControlSearchFind
      Category = 'DevExpress RichEdit Control.Home.Editing'
      Caption = 'Trova'
      ImageIndex = 189
      AssignedValues.Caption = True
    end
    object dxRichEditControlSearchReplace: TdxRichEditControlSearchReplace
      Category = 'DevExpress RichEdit Control.Home.Editing'
      Caption = 'Sostituisci'
      ImageIndex = 192
      AssignedValues.Caption = True
    end
    object dxRichEditControlUndo: TdxRichEditControlUndo
      Category = 'DevExpress RichEdit Control.Home.Editing'
      Caption = 'Annulla'
      ImageIndex = 96
      AssignedValues.Caption = True
    end
    object dxRichEditControlRedo: TdxRichEditControlRedo
      Category = 'DevExpress RichEdit Control.Home.Editing'
      Caption = 'Ripeti'
      ImageIndex = 87
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertPageBreak: TdxRichEditControlInsertPageBreak
      Category = 'DevExpress RichEdit Control.Insert.Pages'
      Caption = 'Interruzione di pagna'
      ImageIndex = 105
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowInsertTableForm: TdxRichEditControlShowInsertTableForm
      Category = 'DevExpress RichEdit Control.Insert.Tables'
      Caption = 'Tabella'
      ImageIndex = 234
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertPicture: TdxRichEditControlInsertPicture
      Category = 'DevExpress RichEdit Control.Insert.Illustrations'
      Caption = 'Immagine da file'
      ImageIndex = 419
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertFloatingObjectPicture: TdxRichEditControlInsertFloatingObjectPicture
      Category = 'DevExpress RichEdit Control.Insert.Illustrations'
      Caption = 'Immagine'
      ImageIndex = 419
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowBookmarkForm: TdxRichEditControlShowBookmarkForm
      Category = 'DevExpress RichEdit Control.Insert.Links'
      Caption = 'Segnalibri'
      ImageIndex = 6
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowHyperlinkForm: TdxRichEditControlShowHyperlinkForm
      Category = 'DevExpress RichEdit Control.Insert.Links'
      ImageIndex = 525
    end
    object dxRichEditControlEditPageHeader: TdxRichEditControlEditPageHeader
      Category = 'DevExpress RichEdit Control.Insert.Header & Footer'
      Caption = 'Intestazione'
      ImageIndex = 291
      AssignedValues.Caption = True
    end
    object dxRichEditControlEditPageFooter: TdxRichEditControlEditPageFooter
      Category = 'DevExpress RichEdit Control.Insert.Header & Footer'
      Caption = 'Pi'#232' di pagina'
      ImageIndex = 290
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertPageNumberField: TdxRichEditControlInsertPageNumberField
      Category = 'DevExpress RichEdit Control.Insert.Header & Footer'
      Caption = 'Numero di pagina'
      ImageIndex = 107
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertPageCountField: TdxRichEditControlInsertPageCountField
      Category = 'DevExpress RichEdit Control.Insert.Header & Footer'
      Caption = 'Totale pagine'
      ImageIndex = 106
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertTextBox: TdxRichEditControlInsertTextBox
      Category = 'DevExpress RichEdit Control.Insert.Text'
      Caption = 'Casella di testo'
      ImageIndex = 121
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowSymbolForm: TdxRichEditControlShowSymbolForm
      Category = 'DevExpress RichEdit Control.Insert.Symbols'
      Caption = 'Simbolo'
      ImageIndex = 351
      AssignedValues.Caption = True
    end
    object dxRichEditControlPageMarginsGallery: TdxRichEditControlPageMarginsGallery
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      Caption = 'Margini'
      ImageIndex = 294
      AssignedValues.Caption = True
      GalleryGroup = dxRibbonGalleryItemMarginsGroup1
    end
    object dxRichEditControlShowPageMarginsSetupForm: TdxRichEditControlShowPageMarginsSetupForm
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 294
    end
    object dxRichEditControlSetPortraitPageOrientation: TdxRichEditControlSetPortraitPageOrientation
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 300
    end
    object dxRichEditControlSetLandscapePageOrientation: TdxRichEditControlSetLandscapePageOrientation
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 299
    end
    object dxRichEditControlPaperSizeGallery: TdxRichEditControlPaperSizeGallery
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      Caption = 'Dimensioni'
      ImageIndex = 306
      AssignedValues.Caption = True
      GalleryGroup = dxRibbonGalleryItemSizeGroup1
    end
    object dxRichEditControlShowPagePaperSetupForm: TdxRichEditControlShowPagePaperSetupForm
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 306
    end
    object dxRichEditControlSetSectionOneColumn: TdxRichEditControlSetSectionOneColumn
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 267
    end
    object dxRichEditControlSetSectionTwoColumns: TdxRichEditControlSetSectionTwoColumns
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 269
    end
    object dxRichEditControlSetSectionThreeColumns: TdxRichEditControlSetSectionThreeColumns
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 268
    end
    object dxRichEditControlShowColumnsSetupForm: TdxRichEditControlShowColumnsSetupForm
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 266
    end
    object dxRichEditControlInsertColumnBreak: TdxRichEditControlInsertColumnBreak
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 99
    end
    object dxRichEditControlInsertSectionBreakNextPage: TdxRichEditControlInsertSectionBreakNextPage
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 110
    end
    object dxRichEditControlInsertSectionBreakEvenPage: TdxRichEditControlInsertSectionBreakEvenPage
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 109
    end
    object dxRichEditControlInsertSectionBreakOddPage: TdxRichEditControlInsertSectionBreakOddPage
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 111
    end
    object dxRichEditControlSetSectionLineNumberingNone: TdxRichEditControlSetSectionLineNumberingNone
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
    end
    object dxRichEditControlSetSectionLineNumberingContinuous: TdxRichEditControlSetSectionLineNumberingContinuous
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
    end
    object dxRichEditControlSetSectionLineNumberingRestartNewPage: TdxRichEditControlSetSectionLineNumberingRestartNewPage
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
    end
    object dxRichEditControlSetSectionLineNumberingRestartNewSection: TdxRichEditControlSetSectionLineNumberingRestartNewSection
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
    end
    object dxRichEditControlShowLineNumberingForm: TdxRichEditControlShowLineNumberingForm
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
    end
    object dxRichEditControlChangePageColor: TdxRichEditControlChangePageColor
      Category = 'DevExpress RichEdit Control.Page Layout.Background'
      Caption = 'Colore pagina'
      ImageIndex = 415
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertTableOfContents: TdxRichEditControlInsertTableOfContents
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
      Caption = 'Sommario'
      ImageIndex = 116
      AssignedValues.Caption = True
    end
    object dxRichEditControlUpdateTableOfContents: TdxRichEditControlUpdateTableOfContents
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
      Caption = 'Aggiorna sommario'
      ImageIndex = 177
      AssignedValues.Caption = True
    end
    object dxRichEditControlAddParagraphsToTableOfContentsPlaceholder: TdxRichEditControlAddParagraphsToTableOfContentsPlaceholder
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
      Caption = 'Aggiungi testo'
      ImageIndex = 51
      AssignedValues.Caption = True
    end
    object dxRichEditControlTableOfContentsSetParagraphBodyTextLevel: TdxRichEditControlTableOfContentsSetParagraphBodyTextLevel
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading1Level: TdxRichEditControlTableOfContentsSetParagraphHeading1Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading2Level: TdxRichEditControlTableOfContentsSetParagraphHeading2Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading3Level: TdxRichEditControlTableOfContentsSetParagraphHeading3Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading4Level: TdxRichEditControlTableOfContentsSetParagraphHeading4Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading5Level: TdxRichEditControlTableOfContentsSetParagraphHeading5Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading6Level: TdxRichEditControlTableOfContentsSetParagraphHeading6Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading7Level: TdxRichEditControlTableOfContentsSetParagraphHeading7Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading8Level: TdxRichEditControlTableOfContentsSetParagraphHeading8Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlTableOfContentsSetParagraphHeading9Level: TdxRichEditControlTableOfContentsSetParagraphHeading9Level
      Category = 'DevExpress RichEdit Control.References.Table of Contents'
    end
    object dxRichEditControlInsertCaptionPlaceholder: TdxRichEditControlInsertCaptionPlaceholder
      Category = 'DevExpress RichEdit Control.References.Captions'
      Caption = 'Inserisci didascalia'
      ImageIndex = 97
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertFigureCaption: TdxRichEditControlInsertFigureCaption
      Category = 'DevExpress RichEdit Control.References.Captions'
      ImageIndex = 104
    end
    object dxRichEditControlInsertTableCaption: TdxRichEditControlInsertTableCaption
      Category = 'DevExpress RichEdit Control.References.Captions'
      ImageIndex = 112
    end
    object dxRichEditControlInsertEquationCaption: TdxRichEditControlInsertEquationCaption
      Category = 'DevExpress RichEdit Control.References.Captions'
      ImageIndex = 103
    end
    object dxRichEditControlInsertTableOfFiguresPlaceholder: TdxRichEditControlInsertTableOfFiguresPlaceholder
      Category = 'DevExpress RichEdit Control.References.Captions'
      Caption = 'Inserisci indice delle figure'
      ImageIndex = 115
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertTableOfFigures: TdxRichEditControlInsertTableOfFigures
      Category = 'DevExpress RichEdit Control.References.Captions'
      ImageIndex = 118
    end
    object dxRichEditControlInsertTableOfTables: TdxRichEditControlInsertTableOfTables
      Category = 'DevExpress RichEdit Control.References.Captions'
      ImageIndex = 112
    end
    object dxRichEditControlInsertTableOfEquations: TdxRichEditControlInsertTableOfEquations
      Category = 'DevExpress RichEdit Control.References.Captions'
      ImageIndex = 117
    end
    object dxRichEditControlUpdateTableOfFigures: TdxRichEditControlUpdateTableOfFigures
      Category = 'DevExpress RichEdit Control.References.Captions'
      Caption = 'Aggiorna tabella'
      ImageIndex = 177
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowInsertMergeFieldForm: TdxRichEditControlShowInsertMergeFieldForm
      Category = 'DevExpress RichEdit Control.Mail Merge.Mail Merge'
      Caption = 'Inserisci Campo Merge'
      ImageIndex = 102
      Visible = False
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowAllFieldCodes: TdxRichEditControlShowAllFieldCodes
      Category = 'DevExpress RichEdit Control.Mail Merge.Mail Merge'
      Caption = 'Mostra Codici'
      ImageIndex = 447
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowAllFieldResults: TdxRichEditControlShowAllFieldResults
      Category = 'DevExpress RichEdit Control.Mail Merge.Mail Merge'
      Caption = 'Mostra Valori'
      ImageIndex = 448
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleViewMergedData: TdxRichEditControlToggleViewMergedData
      Category = 'DevExpress RichEdit Control.Mail Merge.Mail Merge'
      Caption = 'Visualizza dati'
      ImageIndex = 455
      AssignedValues.Caption = True
    end
    object dxRichEditControlCheckSpelling: TdxRichEditControlCheckSpelling
      Category = 'DevExpress RichEdit Control.Review.Proofing'
      Caption = 'Controllo ortografia'
      ImageIndex = 94
      AssignedValues.Caption = True
    end
    object dxRichEditControlProtectDocument: TdxRichEditControlProtectDocument
      Category = 'DevExpress RichEdit Control.Review.Protect'
      Caption = 'Proteggi documento'
      ImageIndex = 493
      AssignedValues.Caption = True
    end
    object dxRichEditControlUnprotectDocument: TdxRichEditControlUnprotectDocument
      Category = 'DevExpress RichEdit Control.Review.Protect'
      Caption = 'Rimuovi protezione'
      ImageIndex = 31
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowRangeEditingPermissions: TdxRichEditControlShowRangeEditingPermissions
      Category = 'DevExpress RichEdit Control.Review.Protect'
      Caption = 'Limita modifiche'
      ImageIndex = 81
      AssignedValues.Caption = True
    end
    object dxRichEditControlEncryptDocument: TdxRichEditControlEncryptDocument
      Category = 'DevExpress RichEdit Control.Review.Protect'
      Caption = 'Crittografia con password'
      ImageIndex = 492
      AssignedValues.Caption = True
    end
    object dxRichEditControlSwitchToSimpleView: TdxRichEditControlSwitchToSimpleView
      Category = 'DevExpress RichEdit Control.View.Document Views'
      Caption = 'Vista semplice'
      ImageIndex = 453
      AssignedValues.Caption = True
    end
    object dxRichEditControlSwitchToDraftView: TdxRichEditControlSwitchToDraftView
      Category = 'DevExpress RichEdit Control.View.Document Views'
      Caption = 'Bozza'
      ImageIndex = 439
      AssignedValues.Caption = True
    end
    object dxRichEditControlSwitchToPrintLayoutView: TdxRichEditControlSwitchToPrintLayoutView
      Category = 'DevExpress RichEdit Control.View.Document Views'
      Caption = 'Layout di stampa'
      ImageIndex = 210
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleShowHorizontalRuler: TdxRichEditControlToggleShowHorizontalRuler
      Category = 'DevExpress RichEdit Control.View.Show'
      Caption = 'Righello orizzontale'
      ImageIndex = 445
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleShowVerticalRuler: TdxRichEditControlToggleShowVerticalRuler
      Category = 'DevExpress RichEdit Control.View.Show'
      Caption = 'Righello verticale'
      ImageIndex = 446
      AssignedValues.Caption = True
    end
    object dxRichEditControlZoomOut: TdxRichEditControlZoomOut
      Category = 'DevExpress RichEdit Control.View.Zoom'
      Caption = 'Riduci'
      ImageIndex = 460
      AssignedValues.Caption = True
    end
    object dxRichEditControlZoomIn: TdxRichEditControlZoomIn
      Category = 'DevExpress RichEdit Control.View.Zoom'
      Caption = 'Ingrandisci'
      ImageIndex = 459
      AssignedValues.Caption = True
    end
    object dxRichEditControlGoToPageHeader: TdxRichEditControlGoToPageHeader
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Navigation'
      Caption = 'Vai all'#39'intestazione'
      ImageIndex = 291
      AssignedValues.Caption = True
    end
    object dxRichEditControlGoToPageFooter: TdxRichEditControlGoToPageFooter
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Navigation'
      Caption = 'Vai al pi'#232' di pagina'
      ImageIndex = 290
      AssignedValues.Caption = True
    end
    object dxRichEditControlGoToNextPageHeaderFooter: TdxRichEditControlGoToNextPageHeaderFooter
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Navigation'
      Caption = 'Successivo'
      ImageIndex = 150
      AssignedValues.Caption = True
    end
    object dxRichEditControlGoToPreviousPageHeaderFooter: TdxRichEditControlGoToPreviousPageHeaderFooter
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Navigation'
      Caption = 'Precedente'
      ImageIndex = 151
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleHeaderFooterLinkToPrevious: TdxRichEditControlToggleHeaderFooterLinkToPrevious
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Navigation'
      Caption = 'Collega a precedente'
      ImageIndex = 158
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleDifferentFirstPage: TdxRichEditControlToggleDifferentFirstPage
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Options'
      Caption = 'Diversi per la prima pagina'
      ImageIndex = 7
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleDifferentOddAndEvenPages: TdxRichEditControlToggleDifferentOddAndEvenPages
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Options'
      Caption = 'Diversi per le pagine pari e dispari'
      ImageIndex = 8
      AssignedValues.Caption = True
    end
    object dxRichEditControlClosePageHeaderFooter: TdxRichEditControlClosePageHeaderFooter
      Category = 'DevExpress RichEdit Control.Header & Footer Design.Close'
      Caption = 'Chiudi intestazione e pi'#232' di pagina'
      ImageIndex = 60
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleShowTableGridLines: TdxRichEditControlToggleShowTableGridLines
      Category = 'DevExpress RichEdit Control.Table Layout.Table'
      Caption = 'Visualizza griglia'
      ImageIndex = 456
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowTablePropertiesForm: TdxRichEditControlShowTablePropertiesForm
      Category = 'DevExpress RichEdit Control.Table Layout.Table'
      Caption = 'Propriet'#224' tabella'
      ImageIndex = 287
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowDeleteTableCellsForm: TdxRichEditControlShowDeleteTableCellsForm
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      ImageIndex = 74
    end
    object dxRichEditControlDeleteTableColumns: TdxRichEditControlDeleteTableColumns
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      ImageIndex = 75
    end
    object dxRichEditControlDeleteTableRows: TdxRichEditControlDeleteTableRows
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      ImageIndex = 76
    end
    object dxRichEditControlDeleteTable: TdxRichEditControlDeleteTable
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      ImageIndex = 73
    end
    object dxRichEditControlInsertTableRowAbove: TdxRichEditControlInsertTableRowAbove
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      Caption = 'Inserisci sopra'
      ImageIndex = 119
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertTableRowBelow: TdxRichEditControlInsertTableRowBelow
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      Caption = 'Inserisci sotto'
      ImageIndex = 120
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertTableColumnToTheLeft: TdxRichEditControlInsertTableColumnToTheLeft
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      Caption = 'Inserisci a sinistra'
      ImageIndex = 113
      AssignedValues.Caption = True
    end
    object dxRichEditControlInsertTableColumnToTheRight: TdxRichEditControlInsertTableColumnToTheRight
      Category = 'DevExpress RichEdit Control.Table Layout.Row & Columns'
      Caption = 'Inserisci a destra'
      ImageIndex = 114
      AssignedValues.Caption = True
    end
    object dxRichEditControlMergeTableCells: TdxRichEditControlMergeTableCells
      Category = 'DevExpress RichEdit Control.Table Layout.Merge'
      Caption = 'Unisci celle'
      ImageIndex = 275
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowSplitTableCellsForm: TdxRichEditControlShowSplitTableCellsForm
      Category = 'DevExpress RichEdit Control.Table Layout.Merge'
      Caption = 'Dividi celle'
      ImageIndex = 280
      AssignedValues.Caption = True
    end
    object dxRichEditControlSplitTable: TdxRichEditControlSplitTable
      Category = 'DevExpress RichEdit Control.Table Layout.Merge'
      Caption = 'Dividi tabella'
      ImageIndex = 279
      AssignedValues.Caption = True
    end
    object dxRichEditControlToggleTableAutoFitContents: TdxRichEditControlToggleTableAutoFitContents
      Category = 'DevExpress RichEdit Control.Table Layout.Cell Size'
      ImageIndex = 285
    end
    object dxRichEditControlToggleTableAutoFitWindow: TdxRichEditControlToggleTableAutoFitWindow
      Category = 'DevExpress RichEdit Control.Table Layout.Cell Size'
      ImageIndex = 286
    end
    object dxRichEditControlToggleTableFixedColumnWidth: TdxRichEditControlToggleTableFixedColumnWidth
      Category = 'DevExpress RichEdit Control.Table Layout.Cell Size'
      ImageIndex = 236
    end
    object dxRichEditControlToggleTableCellsTopLeftAlignment: TdxRichEditControlToggleTableCellsTopLeftAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 321
    end
    object dxRichEditControlToggleTableCellsTopCenterAlignment: TdxRichEditControlToggleTableCellsTopCenterAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 320
    end
    object dxRichEditControlToggleTableCellsTopRightAlignment: TdxRichEditControlToggleTableCellsTopRightAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 322
    end
    object dxRichEditControlToggleTableCellsMiddleLeftAlignment: TdxRichEditControlToggleTableCellsMiddleLeftAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 317
    end
    object dxRichEditControlToggleTableCellsMiddleCenterAlignment: TdxRichEditControlToggleTableCellsMiddleCenterAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 316
    end
    object dxRichEditControlToggleTableCellsMiddleRightAlignment: TdxRichEditControlToggleTableCellsMiddleRightAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 318
    end
    object dxRichEditControlToggleTableCellsBottomLeftAlignment: TdxRichEditControlToggleTableCellsBottomLeftAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 310
    end
    object dxRichEditControlToggleTableCellsBottomCenterAlignment: TdxRichEditControlToggleTableCellsBottomCenterAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 309
    end
    object dxRichEditControlToggleTableCellsBottomRightAlignment: TdxRichEditControlToggleTableCellsBottomRightAlignment
      Category = 'DevExpress RichEdit Control.Table Layout.Alignment'
      ImageIndex = 311
    end
    object dxRichEditControlTableStylesGallery: TdxRichEditControlTableStylesGallery
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 26
      GalleryGroup = dxRibbonGalleryItemTableStylesGroup1
    end
    object dxRichEditControlToggleTableCellsBottomBorder: TdxRichEditControlToggleTableCellsBottomBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 250
    end
    object dxRichEditControlToggleTableCellsTopBorder: TdxRichEditControlToggleTableCellsTopBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 261
    end
    object dxRichEditControlToggleTableCellsLeftBorder: TdxRichEditControlToggleTableCellsLeftBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 255
    end
    object dxRichEditControlToggleTableCellsRightBorder: TdxRichEditControlToggleTableCellsRightBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 257
    end
    object dxRichEditControlResetTableCellsBorders: TdxRichEditControlResetTableCellsBorders
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 256
    end
    object dxRichEditControlToggleTableCellsAllBorders: TdxRichEditControlToggleTableCellsAllBorders
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 248
    end
    object dxRichEditControlToggleTableCellsOutsideBorder: TdxRichEditControlToggleTableCellsOutsideBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 259
    end
    object dxRichEditControlToggleTableCellsInsideBorder: TdxRichEditControlToggleTableCellsInsideBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 258
    end
    object dxRichEditControlToggleTableCellsInsideHorizontalBorder: TdxRichEditControlToggleTableCellsInsideHorizontalBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 253
    end
    object dxRichEditControlToggleTableCellsInsideVerticalBorder: TdxRichEditControlToggleTableCellsInsideVerticalBorder
      Category = 'DevExpress RichEdit Control.Table Design.Table Styles'
      ImageIndex = 254
    end
    object dxRichEditControlChangeFloatingObjectFillColor: TdxRichEditControlChangeFloatingObjectFillColor
      Category = 'DevExpress RichEdit Control.Format.Shape Styles'
      Caption = 'Riempimento forma'
      ImageIndex = 416
      AssignedValues.Caption = True
    end
    object dxRichEditControlChangeFloatingObjectOutlineColor: TdxRichEditControlChangeFloatingObjectOutlineColor
      Category = 'DevExpress RichEdit Control.Format.Shape Styles'
      Caption = 'Contorno forma'
      ImageIndex = 417
      AssignedValues.Caption = True
    end
    object dxRichEditControlSetFloatingObjectSquareTextWrapType: TdxRichEditControlSetFloatingObjectSquareTextWrapType
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 507
    end
    object dxRichEditControlSetFloatingObjectTightTextWrapType: TdxRichEditControlSetFloatingObjectTightTextWrapType
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 432
    end
    object dxRichEditControlSetFloatingObjectThroughTextWrapType: TdxRichEditControlSetFloatingObjectThroughTextWrapType
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 431
    end
    object dxRichEditControlSetFloatingObjectTopAndBottomTextWrapType: TdxRichEditControlSetFloatingObjectTopAndBottomTextWrapType
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 393
    end
    object dxRichEditControlSetFloatingObjectBehindTextWrapType: TdxRichEditControlSetFloatingObjectBehindTextWrapType
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 323
    end
    object dxRichEditControlSetFloatingObjectInFrontOfTextWrapType: TdxRichEditControlSetFloatingObjectInFrontOfTextWrapType
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 338
    end
    object dxRichEditControlSetFloatingObjectTopLeftAlignment: TdxRichEditControlSetFloatingObjectTopLeftAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 396
    end
    object dxRichEditControlSetFloatingObjectTopCenterAlignment: TdxRichEditControlSetFloatingObjectTopCenterAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 395
    end
    object dxRichEditControlSetFloatingObjectTopRightAlignment: TdxRichEditControlSetFloatingObjectTopRightAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 397
    end
    object dxRichEditControlSetFloatingObjectMiddleLeftAlignment: TdxRichEditControlSetFloatingObjectMiddleLeftAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 182
    end
    object dxRichEditControlSetFloatingObjectMiddleCenterAlignment: TdxRichEditControlSetFloatingObjectMiddleCenterAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 361
    end
    object dxRichEditControlSetFloatingObjectMiddleRightAlignment: TdxRichEditControlSetFloatingObjectMiddleRightAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 183
    end
    object dxRichEditControlSetFloatingObjectBottomLeftAlignment: TdxRichEditControlSetFloatingObjectBottomLeftAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 180
    end
    object dxRichEditControlSetFloatingObjectBottomCenterAlignment: TdxRichEditControlSetFloatingObjectBottomCenterAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 360
    end
    object dxRichEditControlSetFloatingObjectBottomRightAlignment: TdxRichEditControlSetFloatingObjectBottomRightAlignment
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 181
    end
    object dxRichEditControlFloatingObjectBringForward: TdxRichEditControlFloatingObjectBringForward
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 411
    end
    object dxRichEditControlFloatingObjectBringToFront: TdxRichEditControlFloatingObjectBringToFront
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 412
    end
    object dxRichEditControlFloatingObjectBringInFrontOfText: TdxRichEditControlFloatingObjectBringInFrontOfText
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 413
    end
    object dxRichEditControlFloatingObjectSendBackward: TdxRichEditControlFloatingObjectSendBackward
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 429
    end
    object dxRichEditControlFloatingObjectSendToBack: TdxRichEditControlFloatingObjectSendToBack
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 430
    end
    object dxRichEditControlFloatingObjectSendBehindText: TdxRichEditControlFloatingObjectSendBehindText
      Category = 'DevExpress RichEdit Control.Format.Arrange'
      ImageIndex = 468
    end
    object dxRichEditControlShowPrintForm: TdxRichEditControlShowPrintForm
      Category = 'DevExpress RichEdit Control.File.Print'
      Caption = 'Stampa'
      ImageIndex = 208
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowPrintPreviewForm: TdxRichEditControlShowPrintPreviewForm
      Category = 'DevExpress RichEdit Control.File.Print'
      Caption = 'Anteprima'
      ImageIndex = 169
      AssignedValues.Caption = True
    end
    object dxRichEditControlShowPageSetupForm: TdxRichEditControlShowPageSetupForm
      Category = 'DevExpress RichEdit Control.File.Print'
      Caption = 'Propriet'#224' stampante'
      ImageIndex = 517
      AssignedValues.Caption = True
    end
    object actExportPDF: TAction
      Caption = 'Esporta in PDF'
      ImageIndex = 363
      OnExecute = actExportPDFExecute
    end
    object dxRichEditControlShowMergeDatabaseRecordsForm: TdxRichEditControlShowMergeDatabaseRecordsForm
      Category = 'DevExpress RichEdit Control.Mail Merge.Mail Merge'
      ImageIndex = 465
    end
    object ApriCartella: TAction
      Caption = 'Apri Cartella'
      ImageIndex = 2
    end
    object actPoliticheAccessi: TAction
      Caption = 'Politiche Accessi'
      ImageIndex = 497
    end
    object actRicaricaPolitiche: TAction
      Caption = 'Ricarica Politiche'
      ImageIndex = 22
    end
    object ElencoCampiUtilizzati: TAction
      Caption = 'Elenco Campi Utilizzati'
      ImageIndex = 455
      OnExecute = ElencoCampiUtilizzatiExecute
    end
    object actPermessiAzione: TAction
      Caption = 'Permessi'
      ImageIndex = 81
    end
    object Chiudi: TAction
      Caption = 'Chiudi'
      ImageIndex = 60
      OnExecute = ChiudiExecute
    end
  end
  object dxRibbonPopupMenu1: TdxRibbonPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarLargeButtonDoNotShowinTableofContents'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel1'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel2'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel3'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel4'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel5'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel6'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel7'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel8'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonLevel9'
      end>
    Ribbon = dxRibbon
    UseOwnFont = False
    Left = 720
    Top = 208
    PixelsPerInch = 96
  end
  object dxRibbonPopupMenu2: TdxRibbonPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarLargeButtonFiguresCaption'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonTablesCaption'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonEquationsCaption'
      end>
    Ribbon = dxRibbon
    UseOwnFont = False
    Left = 720
    Top = 264
    PixelsPerInch = 96
  end
  object dxRibbonPopupMenu3: TdxRibbonPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarLargeButtonTableofFigures'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonTableofTables'
      end
      item
        Visible = True
        ItemName = 'dxBarLargeButtonTableofEquations'
      end>
    Ribbon = dxRibbon
    UseOwnFont = False
    Left = 720
    Top = 320
    PixelsPerInch = 96
  end
  object Printer: TdxComponentPrinter
    CurrentLink = PrinterLink
    PreviewOptions.SaveZoomPosition = False
    PreviewOptions.Caption = 'Anteprima'
    PreviewOptions.WindowState = wsMaximized
    PreviewOptions.PreviewBoundsRect = {0000000000000000E803000020030000}
    Version = 0
    Left = 112
    Top = 408
    PixelsPerInch = 96
    object PrinterLink: TdxRichEditControlReportLink
      Active = True
      Component = dxRichEditControl
      PrinterPage.DMPaper = 9
      PrinterPage.Footer = 6350
      PrinterPage.GrayShading = True
      PrinterPage.Header = 6350
      PrinterPage.Margins.Bottom = 12700
      PrinterPage.Margins.Left = 12700
      PrinterPage.Margins.Right = 12700
      PrinterPage.Margins.Top = 12700
      PrinterPage.Orientation = poLandscape
      PrinterPage.PageSize.X = 210000
      PrinterPage.PageSize.Y = 297000
      PrinterPage._dxMeasurementUnits_ = 0
      PrinterPage._dxLastMU_ = 2
      ReportDocument.CreationDate = 45769.758913576390000000
      PixelsPerInch = 96
      BuiltInReportLink = True
    end
  end
  object dxSaveFileDialogPDF: TdxSaveFileDialog
    DefaultExt = '*.PDF'
    Filter = 
      'pdf (nessun font incluso)|*.pdf|pdf (includi font completi)|*.pd' +
      'f|pdf (includi font subset)|*.pdf|Tutti|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Left = 112
    Top = 488
  end
  object popActions: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton1'
      end>
    UseOwnFont = False
    Left = 112
    Top = 229
    PixelsPerInch = 96
  end
  object dxSaveFileDialogDocx: TdxSaveFileDialog
    DefaultExt = '*.docx'
    Filter = 'Word|*.docx|Tutti|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing]
    Left = 112
    Top = 552
  end
end
