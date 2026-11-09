object zLocalizerForm: TzLocalizerForm
  Left = 749
  Top = 182
  BorderIcons = [biMaximize]
  Caption = 'Form Localizer'
  ClientHeight = 602
  ClientWidth = 774
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  TextHeight = 13
  object OkCancel: TOkCancel
    Left = 0
    Top = 572
    Width = 774
    Height = 30
    Align = alBottom
    TabOrder = 0
    OnApply = OkCancelApply
     
    DefaultOk = False
    DefaultCancel = False
    ExplicitTop = 573
    ExplicitWidth = 778
  end
  object tree: TcxTreeList
    AlignWithMargins = True
    Left = 3
    Top = 31
    Width = 768
    Height = 538
    Margins.Top = 7
    Align = alClient
    Bands = <
      item
        Caption.Text = 'Resources'
        FixedKind = tlbfLeft
        Width = 400
      end
      item
        Caption.Text = 'Lingue'
      end>
    FindPanel.DisplayMode = fpdmManual
    Images = treeImages
    OptionsBehavior.ExpandOnIncSearch = True
    OptionsBehavior.IncSearch = True
    OptionsBehavior.MultiSort = False
    OptionsCustomizing.BandsQuickCustomization = True
    OptionsCustomizing.ColumnHiding = True
    OptionsCustomizing.ColumnsQuickCustomization = True
    OptionsCustomizing.NodeSizing = True
    OptionsData.CaseInsensitive = True
    OptionsData.Deleting = False
    OptionsData.MultiThreadedSorting = bFalse
    OptionsSelection.HideFocusRect = False
    OptionsSelection.InvertSelect = False
    OptionsView.CategorizedColumn = colNamespace
    OptionsView.ColumnAutoWidth = True
    OptionsView.DropNodeIndicator = True
    OptionsView.FixedSeparatorColor = clNone
    OptionsView.FixedSeparatorWidth = 1
    OptionsView.GridLineColor = clInactiveBorder
    OptionsView.GridLines = tlglBoth
    OptionsView.Indicator = True
    OptionsView.PaintStyle = tlpsCategorized
    OptionsView.SimpleCustomizeBox = True
    PopupMenus.ColumnHeaderMenu.UseBuiltInMenu = True
    PopupMenus.FooterMenu.UseBuiltInMenu = True
    PopupMenus.GroupFooterMenu.UseBuiltInMenu = True
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 5
    OnColumnHeaderClick = treeColumnHeaderClick
    OnFocusedColumnChanged = treeFocusedColumnChanged
    OnSelectionChanged = treeSelectionChanged
    ExplicitTop = 29
    ExplicitWidth = 772
    ExplicitHeight = 541
    object colNamespace: TcxTreeListColumn
      PropertiesClassName = 'TcxLabelProperties'
      Properties.PenWidth = 0
      Caption.AlignVert = vaTop
      Caption.Text = 'Namespace'
      MinWidth = 10
      Options.Sizing = False
      Options.Customizing = False
      Options.Editing = False
      Options.Moving = False
      Width = 100
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
    object colResourceName: TcxTreeListColumn
      PropertiesClassName = 'TcxLabelProperties'
      Caption.Text = 'ResourceName'
      Options.Editing = False
      Width = 100
      Position.ColIndex = 1
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 336
    Top = 118
    object ApplyBestWidth: TAction
      Caption = 'Incolonna'
      ImageIndex = 438
      OnExecute = ApplyBestWidthExecute
    end
    object AddLanguage: TAction
      Caption = 'Nuova Lingua'
      ImageIndex = 1
      OnExecute = AddLanguageExecute
    end
    object DeleteLanguage: TAction
      Caption = 'Elimina Lingua'
      ImageIndex = 66
      OnExecute = DeleteLanguageExecute
    end
    object Esporta: TdxFileSaveAs
      Caption = 'Esporta'
      Dialog.DefaultExt = '*.txt'
      Dialog.Filter = 'Testo|*.txt|Tutti|*.*'
      ImageIndex = 221
      BeforeExecute = EsportaBeforeExecute
      OnAccept = EsportaAccept
      OnUpdate = EsportaUpdate
    end
    object Importa: TdxFileOpen
      Caption = 'Importa'
      Dialog.DefaultExt = '*.txt'
      Dialog.Filter = 'Testo|*.txt|Tutti|*.*'
      ImageIndex = 238
      BeforeExecute = ImportaBeforeExecute
      OnAccept = ImportaAccept
      OnUpdate = ImportaUpdate
    end
    object CopiaFile: TdxFileSaveAs
      Caption = 'Copia file'
      ImageIndex = 92
      BeforeExecute = CopiaFileBeforeExecute
      OnAccept = CopiaFileAccept
      OnUpdate = CopiaFileUpdate
    end
    object Espandi: TAction
      Caption = 'Espandi'
      ImageIndex = 144
      OnExecute = EspandiExecute
    end
    object Raccogli: TAction
      Caption = 'Raccogli'
      ImageIndex = 537
      OnExecute = RaccogliExecute
    end
    object ColumnAutoWidth: TAction
      Caption = 'Espandi'
      ImageIndex = 144
      OnExecute = ColumnAutoWidthExecute
    end
    object Sostituisci: TAction
      Caption = 'Sostituisci'
      ImageIndex = 192
      ShortCut = 16456
      OnExecute = SostituisciExecute
    end
  end
  object treeImages: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 15466831
    ImageInfo = <
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D2270757A7A6C655F
          706965636522207472616E73666F726D3D227363616C6528312E333333333333
          29223E0A093C7061746820643D224D313320324331342E33363420322031352E
          3436393720332E31303537322031352E3436393720342E343639374C31352E34
          363920354831394331392E35353233203520323020352E343437373220323020
          364C31392E39393920392E3439394C31382E3436393720392E354331372E3136
          303320392E352031362E303838392031302E3531392031362E30303533203131
          2E383037334C31362031312E393639375631322E303330334331362031332E33
          3339372031372E3031392031342E343131312031382E333037332031342E3439
          34374C31382E343639372031342E354C31392E3939392031342E3439394C3230
          2031382E303032394332302031382E353535322031392E353532332031392E30
          3032392031392031392E303032394C31352E3436392031392E3030324C31352E
          343639372031392E353330334331352E343639372032302E383934332031342E
          3336342032322031332032324331312E3633362032322031302E353330332032
          302E383934332031302E353330332031392E353330334C31302E35332031392E
          3030324C372031392E3030323943362E34343737322031392E30303239203620
          31382E3535353220362031382E303032394C352E3939392031342E3437314C35
          2E343639372031342E3437313243342E31303537322031342E34373132203320
          31332E3336353420332031322E3030313543332031302E3633373520342E3130
          35373220392E353331373720352E3436393720392E35333137374C352E393939
          20392E3533314C362036433620352E343437373220362E343437373220352037
          20354831302E35334C31302E3533303320342E343639374331302E3533303320
          332E31303537322031312E363336203220313320325A2220636C6173733D2242
          6C61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'puzzle_piece.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D2270757A7A6C655F
          706965636522207472616E73666F726D3D227363616C6528312E333333333333
          29223E0A093C7061746820643D224D313320324331342E33363420322031352E
          3436393720332E31303537322031352E3436393720342E343639374C31352E34
          363920354831394331392E35353233203520323020352E343437373220323020
          364C31392E39393920392E3439394C31382E3436393720392E354331372E3136
          303320392E352031362E303838392031302E3531392031362E30303533203131
          2E383037334C31362031312E393639375631322E303330334331362031332E33
          3339372031372E3031392031342E343131312031382E333037332031342E3439
          34374C31382E343639372031342E354C31392E3939392031342E3439394C3230
          2031382E303032394332302031382E353535322031392E353532332031392E30
          3032392031392031392E303032394C31352E3436392031392E3030324C31352E
          343639372031392E353330334331352E343639372032302E383934332031342E
          3336342032322031332032324331312E3633362032322031302E353330332032
          302E383934332031302E353330332031392E353330334C31302E35332031392E
          3030324C372031392E3030323943362E34343737322031392E30303239203620
          31382E3535353220362031382E303032394C352E3939392031342E3437314C35
          2E343639372031342E3437313243342E31303537322031342E34373132203320
          31332E3336353420332031322E3030313543332031302E3633373520342E3130
          35373220392E353331373720352E3436393720392E35333137374C352E393939
          20392E3533314C362036433620352E343437373220362E343437373220352037
          20354831302E35334C31302E3533303320342E343639374331302E3533303320
          332E31303537322031312E363336203220313320325A2220636C6173733D2242
          6C61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'puzzle_piece.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E31222069643D224C61
          7965725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F
          323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F7777
          772E77332E6F72672F313939392F786C696E6B2220783D223070782220793D22
          307078220A092076696577426F783D2230203020333220333222207374796C65
          3D22656E61626C652D6261636B67726F756E643A6E6577203020302033322033
          323B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C65
          20747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A23
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D22746F6F6C732220
          7472616E73666F726D3D227363616C6528312E33333333333329223E0A093C70
          61746820643D224D32312E37312032302E32394C32302E32392032312E373141
          3120312030203020312031382E38382032312E37314C3720392E383541332E38
          3120332E383120302030203120362031304134203420302030203120322E3232
          20342E374C342E373620372E32344C352E323920362E37314C362E373120352E
          32394C372E323420342E37364C342E3720322E32324134203420302030203120
          3130203641332E383120332E383120302030203120392E383520374C32312E37
          312031382E3838413120312030203020312032312E37312032302E32394D322E
          32392031382E38384131203120302030203020322E32392032302E32394C332E
          37312032312E37314131203120302030203020352E31322032312E37314C3130
          2E35392031362E32354C372E37362031332E34324D323020324C313620345636
          4C31332E383320382E31374C31352E38332031302E31374C313820384832304C
          323220345A2220636C6173733D22426C61636B22202F3E0A3C2F673E0A3C2F73
          76673E0A}
        FileName = 'tools.svg'
      end>
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    CanCustomize = False
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.Images = dx.Immagini
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 336
    Top = 64
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      24
      0)
    object dxBarManagerBar1: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      BorderStyle = bbsNone
      Caption = 'Main'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 763
      FloatTop = 8
      FloatClientWidth = 102
      FloatClientHeight = 48
      ItemLinks = <
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton8'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton6'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton9'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton5'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton12'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton4'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton3'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton11'
        end>
      NotDocking = [dsNone]
      OneOnRow = True
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = True
    end
    object dxBarButton1: TdxBarButton
      Action = AddLanguage
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = DeleteLanguage
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton9: TdxBarButton
      Action = ApplyBestWidth
      Category = 0
    end
    object dxBarSubItemAccess: TdxBarSubItem
      Caption = 'Access'
      Category = 0
      Visible = ivAlways
      ImageIndex = 490
      ItemLinks = <>
    end
    object dxBarButton10: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton3: TdxBarButton
      Action = Importa
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = Esporta
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = ColumnAutoWidth
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = Raccogli
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = Espandi
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = CopiaFile
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Action = Sostituisci
      Category = 0
    end
  end
  object cxEditRepository: TcxEditRepository
    Left = 336
    Top = 296
    PixelsPerInch = 96
    object cxEditRepositoryTextItem: TcxEditRepositoryTextItem
    end
  end
  object ReplaceDialog: TReplaceDialog
    OnClose = ReplaceDialogClose
    Options = [frDown, frHideMatchCase, frHideWholeWord, frHideUpDown]
    OnFind = ReplaceDialogFind
    OnReplace = ReplaceDialogReplace
    Left = 336
    Top = 368
  end
end
