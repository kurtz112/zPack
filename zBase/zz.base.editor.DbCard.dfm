inherited zFrameEditor_DbCard: TzFrameEditor_DbCard
  AlignWithMargins = True
  Width = 931
  Height = 572
  Margins.Left = 7
  Margins.Top = 5
  Margins.Right = 7
  ParentShowHint = False
  ShowHint = True
  ExplicitWidth = 931
  ExplicitHeight = 572
  object layout: TdxLayoutControl
    Left = 0
    Top = 22
    Width = 931
    Height = 550
    Align = alClient
    TabOrder = 0
    object tree: TcxTreeList
      Left = 10
      Top = 10
      Width = 641
      Height = 530
      Bands = <
        item
        end>
      DragMode = dmAutomatic
      FindPanel.Behavior = fcbFilter
      FindPanel.DisplayMode = fpdmAlways
      FindPanel.Layout = fplCompact
      FindPanel.UseExtendedSyntax = True
      Navigator.Buttons.CustomButtons = <>
      OptionsBehavior.CellHints = True
      OptionsBehavior.ImmediateEditor = False
      OptionsBehavior.ChangeDelay = 1000
      OptionsBehavior.DragDropText = True
      OptionsBehavior.DragFocusing = True
      OptionsBehavior.IncSearch = True
      OptionsBehavior.IncSearchItem = treeName
      OptionsBehavior.Sorting = False
      OptionsCustomizing.BandsQuickCustomization = True
      OptionsCustomizing.ColumnFiltering = bTrue
      OptionsCustomizing.ColumnsQuickCustomization = True
      OptionsData.Deleting = False
      OptionsData.ImmediatePost = True
      OptionsSelection.MultiSelect = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.DropNodeIndicator = True
      OptionsView.ExtPaintStyle = True
      OptionsView.Indicator = True
      OptionsView.SimpleCustomizeBox = True
      PopupMenu = popTree
      ScrollbarAnnotations.CustomAnnotations = <>
      TabOrder = 0
      OnCustomDrawDataCell = treeCustomDrawDataCell
      OnDragDrop = treeDragDrop
      OnDragOver = treeDragOver
      OnEditValueChanged = treeEditValueChanged
      OnEndDrag = treeEndDrag
      OnGetDragDropText = treeGetDragDropText
      OnKeyDown = treeKeyDown
      OnMoveTo = treeMoveTo
      OnSelectionChanged = treeSelectionChanged
      object treeVisible: TcxTreeListColumn
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.Glyph.SourceDPI = 96
        Properties.Glyph.Data = {
          89504E470D0A1A0A0000000D494844520000002000000010080600000077007D
          59000000017352474200AECE1CE90000000467414D410000B18F0BFC61050000
          00097048597300000EC300000EC301C76FA864000002BC49444154484BED93DF
          4B53611CC60F8D609623496B13742839CDCD4445A2D4B9D265E9042DDD59AB1D
          07ED87E68F503715534A2B6C665068A42D2DAC2470D6852B2C08112C30D01508
          5E65E0456051F40F1C797ADFD3B910F4A878ED071E78F83ECFF79C97C37B981D
          3641266ABB6C6FDFC830DC09860915300C4F453D9D89F1A644A4EEE614DA5DA1
          F0230C4F453D9D89F1C69C91C9FC36B91CC3E5E598ECEAC294CF87672C0B2E2C
          0C34136B92EC3F2AF7C7E6EF4355F7453C7875070F5FDF45750F07B531023413
          6BEB734E2EE72E9117051D0EBCF37830D1D040542FF8374E271C242B95CB6D62
          7D0D2AC31E4E5DA440F3900B375F36A173C443D428F8962795509B145019F64A
          EE33E6F0F0D0804683F1F32C82560BDE725641D48F93AFF08864B423D6D71073
          5211D2B725A2768845DD9005F54FAD82A8AF79CCC2D09E88983CC5FAFB667259
          DC91917C204587609E1EEF4B4EE383B95810F5743646327754144FBBE2DA6A64
          8965517CC1FD2458FD59700D1B51335228887A3A2BB87718B443BBFF5756411F
          5AA752F19359C7305D7C0A9F6DA59875B19875B2829F361931997D1C57A2A325
          0FA0AD50F265CF33E008E8D1182CC4D58912B41251EF18D5A3EC4506B476E5FA
          07A0B895CAD0C7DC1C2C70667CF73AB1D4512B68D1EBC282AD1C9F0C7A54928E
          585F43127B30C40632E1992A826FC686BE39177AE71CB83D73018D646619CB44
          92457A9F215F80EBD56AF1C36EC59F2E2FFEFA3B893AF0FB964798F56975F0A8
          D592BF93CE7E80CBB99680A62F260C2C5EC6E8528BA0FE6F55F07E3521F7BA06
          3ABB6AE3DFB1293EDE3F98968665770556066E60A5BF13CB2E0E83E9E9A09958
          9324D515E3CFF725A37DFE2C02BFC8017E36A36DBE14F9DDC9A09958DB98B6B8
          38AEF59026D4A34DE1A9A8A73331DE94F46A3597511D1BCA6E4DE07388A8A733
          31DE3AF4B2495CB8AD6126BB543B48C230FF0092AC63D6AF1FE97F0000000049
          454E44AE426082}
        Properties.GlyphCount = 2
        Properties.ImmediatePost = True
        BestFitMaxWidth = 40
        Caption.Text = 'Visible'
        MinWidth = 40
        Options.Sizing = False
        Width = 40
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object treeName: TcxTreeListColumn
        PropertiesClassName = 'TcxTextEditProperties'
        Caption.Text = 'Name'
        Width = 100
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object treeDisplayLabel: TcxTreeListColumn
        Caption.Text = 'DisplayLabel'
        Width = 100
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object treeRequired: TcxTreeListColumn
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.Glyph.SourceHeight = 16
        Properties.GlyphCount = 0
        Properties.ImmediatePost = True
        BestFitMaxWidth = 60
        Caption.Text = 'Required'
        MinWidth = 60
        Options.Sizing = False
        Width = 60
        Position.ColIndex = 3
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object treeReadOnly: TcxTreeListColumn
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.Glyph.SourceHeight = 16
        Properties.GlyphCount = 0
        Properties.ImmediatePost = True
        BestFitMaxWidth = 60
        Caption.Text = 'ReadOnly'
        MinWidth = 60
        Options.Sizing = False
        Width = 60
        Position.ColIndex = 4
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object treeSize: TcxTreeListColumn
        PropertiesClassName = 'TcxSpinEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ImmediatePost = True
        Properties.LargeIncrement = 5.000000000000000000
        BestFitMaxWidth = 50
        Caption.Text = 'Size'
        MinWidth = 50
        Options.Sizing = False
        Width = 50
        Position.ColIndex = 5
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object treeLines: TcxTreeListColumn
        PropertiesClassName = 'TcxSpinEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.ImmediatePost = True
        BestFitMaxWidth = 50
        Caption.Text = 'Lines'
        MinWidth = 50
        Options.Sizing = False
        Width = 50
        Position.ColIndex = 6
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
      object treeCtrlType: TcxTreeListColumn
        PropertiesClassName = 'TcxImageComboBoxProperties'
        Properties.Images = imageCtrlType
        Properties.Items = <
          item
            Description = 'Empty'
            ImageIndex = 2
            Value = 0
          end
          item
            Description = 'Group'
            ImageIndex = 3
            Value = 1
          end
          item
            Description = 'Simple'
            ImageIndex = 4
            Value = 2
          end
          item
            Description = 'Tabbed'
            ImageIndex = 1
            Value = 3
          end
          item
            Description = 'Button'
            ImageIndex = 5
            Value = 4
          end>
        Properties.ReadOnly = False
        BestFitMaxWidth = 130
        Caption.Text = 'CtrlType'
        MinWidth = 130
        Options.Sizing = False
        Width = 130
        Position.ColIndex = 7
        Position.RowIndex = 0
        Position.BandIndex = 0
        Summary.FooterSummaryItems = <>
        Summary.GroupFooterSummaryItems = <>
      end
    end
    object Inspector: TFrameObjectInspector
      AlignWithMargins = True
      Left = 665
      Top = 10
      Width = 256
      Height = 530
      TabOrder = 1
    end
    object layoutGroup_Root: TdxLayoutGroup
      AlignHorz = ahClient
      AlignVert = avClient
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = -1
    end
    object dxLayoutItemTree: TdxLayoutItem
      Parent = dxLayoutGroupMain
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'Controls'
      CaptionOptions.Visible = False
      Control = tree
      ControlOptions.OriginalHeight = 315
      ControlOptions.OriginalWidth = 500
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutGroupMain: TdxLayoutGroup
      Parent = layoutGroup_Root
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'New Group'
      CaptionOptions.Visible = False
      LayoutDirection = ldHorizontal
      ShowBorder = False
      Index = 0
    end
    object dxLayoutSplitterItem6: TdxLayoutSplitterItem
      Parent = dxLayoutGroupMain
      SizeOptions.AssignedValues = [sovSizableHorz, sovSizableVert]
      SizeOptions.SizableHorz = False
      SizeOptions.SizableVert = False
      CaptionOptions.Text = 'Splitter'
      Index = 1
    end
    object dxLayoutItemInspector: TdxLayoutItem
      Parent = dxLayoutGroupMain
      AlignHorz = ahClient
      AlignVert = avClient
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = Inspector
      ControlOptions.AutoColor = True
      ControlOptions.OriginalHeight = 255
      ControlOptions.OriginalWidth = 200
      ControlOptions.ShowBorder = False
      Index = 2
    end
  end
  object pnlSposta: TPanel
    Left = 88
    Top = 160
    Width = 225
    Height = 265
    ShowCaption = False
    TabOrder = 1
    Visible = False
    OnMouseDown = pnlSpostaMouseDown
    OnMouseMove = pnlSpostaMouseMove
    OnMouseUp = pnlSpostaMouseUp
    DesignSize = (
      225
      265)
    object cxButton1: TcxButton
      Left = 144
      Top = 235
      Width = 75
      Height = 25
      Action = SpostaCampi
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object treeSposta: TcxTreeView
      AlignWithMargins = True
      Left = 2
      Top = 2
      Width = 221
      Height = 227
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 35
      Align = alClient
      TabOrder = 1
      OnDblClick = treeSpostaDblClick
      Images = ItemImages
    end
  end
  object ItemImages: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 5243320
    ImageInfo = <
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C61636B7B66696C6C3A2337
          32373237323B7D0A092E426C75657B66696C6C3A233131373744373B7D0A3C2F
          7374796C653E0A3C7061746820636C6173733D22426C61636B2220643D224D32
          362C3134763132483130762D34762D32762D3648387636483656366831367638
          6832563563302D302E362D302E342D312D312D31483543342E342C342C342C34
          2E342C342C3576313663302C302E362C302E342C312C312C31683376350A0963
          302C302E352C302E352C312C312C3168313863302E352C302C312D302E352C31
          2D315631344832367A222F3E0A3C7061746820636C6173733D22426C75652220
          643D224D32382C313163302D302E362D302E342D312D312D314839632D302E36
          2C302D312C302E342D312C317632763176326832305631317A222F3E0A3C2F73
          76673E0A}
        FileName = 'action_windowlist.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032322E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E5265647B66696C6C3A234431314331433B7D0A092E477265656E7B66696C6C
          3A233033394332333B7D0A092E59656C6C6F777B66696C6C3A23464642313135
          3B7D0A092E57686974657B66696C6C3A234646464646463B7D0A092E7374307B
          6F7061636974793A302E353B7D0A092E7374317B6F7061636974793A302E3735
          3B7D0A092E7374327B646973706C61793A6E6F6E653B7D0A092E7374337B6469
          73706C61793A696E6C696E653B66696C6C3A234646423131353B7D0A092E7374
          347B646973706C61793A696E6C696E653B7D0A092E7374357B646973706C6179
          3A696E6C696E653B6F7061636974793A302E37353B7D0A092E7374367B646973
          706C61793A696E6C696E653B6F7061636974793A302E353B7D0A092E7374377B
          646973706C61793A696E6C696E653B66696C6C3A233033394332333B7D0A092E
          7374387B646973706C61793A696E6C696E653B66696C6C3A234431314331433B
          7D0A092E7374397B646973706C61793A696E6C696E653B66696C6C3A23313137
          3744373B7D0A092E737431307B646973706C61793A696E6C696E653B66696C6C
          3A234646464646463B7D0A3C2F7374796C653E0A3C672069643D22466F6C6465
          72223E0A093C6720636C6173733D22737431223E0A09093C7061746820636C61
          73733D2259656C6C6F772220643D224D322E322C32352E326C352E352D313043
          382C31342E352C382E372C31342C392E352C3134483234762D3363302D302E36
          2D302E342D312D312D31483132563763302D302E362D302E342D312D312D3148
          3343322E342C362C322C362E352C322C377631380A09090963302C302E322C30
          2C302E332C302E312C302E3443322E312C32352E342C322E322C32352E332C32
          2E322C32352E327A222F3E0A093C2F673E0A093C7061746820636C6173733D22
          59656C6C6F772220643D224D32392E332C313648392E364C342C32366831392E
          3863302E352C302C312E312D302E322C312E332D302E366C342E392D382E3943
          33302E312C31362E322C32392E382C31362C32392E332C31367A222F3E0A3C2F
          673E0A3C2F7376673E0A}
        FileName = 'bo_folder.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C7376672076657273696F6E3D22312E31222069643D224C617965725F312220
          786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F7376
          672220786D6C6E733A786C696E6B3D22687474703A2F2F7777772E77332E6F72
          672F313939392F786C696E6B2220783D223070782220793D22307078220A0920
          76696577426F783D2230203020313620313622207374796C653D22656E61626C
          652D6261636B67726F756E643A6E6577203020302031362031363B2220786D6C
          3A73706163653D227072657365727665223E0A3C7374796C6520747970653D22
          746578742F637373223E0A092E426C61636B7B66696C6C3A233537353735353B
          7D0A092E426C75657B66696C6C3A233131373744373B7D0A3C2F7374796C653E
          0A3C7061746820636C6173733D22477265656E2220643D224D31352E352C3131
          48313356382E354331332C382E322C31322E382C382C31322E352C38682D3143
          31312E322C382C31312C382E322C31312C382E3556313148382E3543382E322C
          31312C382C31312E322C382C31312E3576310A0943382C31322E382C382E322C
          31332C382E352C313348313176322E3563302C302E332C302E322C302E352C30
          2E352C302E35683163302E332C302C302E352D302E322C302E352D302E355631
          3368322E3563302E332C302C302E352D302E322C302E352D302E35762D310A09
          4331362C31312E322C31352E382C31312C31352E352C31317A222F3E0A3C7061
          746820636C6173733D22426C75652220643D224D31322E352C37682D31314331
          2E322C372C312C362E382C312C362E35762D3143312C352E322C312E322C352C
          312E352C356831314331322E382C352C31332C352E322C31332C352E3576310A
          094331332C362E382C31322E382C372C31322E352C377A222F3E0A3C2F737667
          3E0A}
        FileName = 'addseparator.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C7376672076657273696F6E3D22312E31222069643D224C617965725F312220
          786D6C6E733D22687474703A2F2F7777772E77332E6F72672F323030302F7376
          672220786D6C6E733A786C696E6B3D22687474703A2F2F7777772E77332E6F72
          672F313939392F786C696E6B2220783D223070782220793D22307078220A0920
          76696577426F783D2230203020313620313622207374796C653D22656E61626C
          652D6261636B67726F756E643A6E6577203020302031362031363B2220786D6C
          3A73706163653D227072657365727665223E0A3C7374796C6520747970653D22
          746578742F637373223E0A092E426C61636B7B66696C6C3A233537353735357D
          0A092E426C75657B66696C6C3A233131373744377D0A3C2F7374796C653E0A3C
          7061746820636C6173733D22477265656E2220643D224D31352E352C31314831
          3356382E354331332C382E322C31322E382C382C31322E352C38682D31433131
          2E322C382C31312C382E322C31312C382E3556313148382E3543382E322C3131
          2C382C31312E322C382C31312E3576310A0943382C31322E382C382E322C3133
          2C382E352C313348313176322E3563302C302E332C302E322C302E352C302E35
          2C302E35683163302E332C302C302E352D302E322C302E352D302E3556313368
          322E3563302E332C302C302E352D302E322C302E352D302E35762D310A094331
          362C31312E322C31352E382C31312C31352E352C31317A222F3E0A3C70617468
          20636C6173733D22426C75652220643D224D342C3468352E3543392E382C342C
          31302C342E322C31302C342E3576354331302C392E382C392E382C31302C392E
          352C3130682D3543342E322C31302C342C392E382C342C392E3556347A204D33
          2C332E350A0943332C332E322C332E322C332C332E352C33483756312E354337
          2C312E322C362E382C312C362E352C31682D3543312E322C312C312C312E322C
          312C312E35763543312C362E382C312E322C372C312E352C37483356332E357A
          222F3E0A3C2F7376673E0A}
        FileName = 'addgroup.svg'
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
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D22666F726D2D6472
          6F70646F776E22207472616E73666F726D3D227363616C6528312E3333333333
          3329223E0A093C7061746820643D224D313720354832304C31382E3520374C31
          3720354D3320324832314332322E3131203220323320322E3920323320345638
          43323320392E31312032322E3131203130203231203130483136563230433136
          2032312E31312031352E3131203232203134203232483343312E392032322031
          2032312E313120312032305634433120322E3920312E392032203320324D3320
          345638483134563448334D32312038563448313656384832314D332032304831
          3456313048335632304D3520313248313256313448355631324D352031364831
          3256313848355631365A2220636C6173733D22426C61636B22202F3E0A3C2F67
          3E0A3C2F7376673E0A}
        FileName = 'form-dropdown.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E477265656E7B66696C6C3A233033394332333B7D0A092E477265656E7B6669
          6C6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B
          7D0A092E7374307B6F7061636974793A302E37353B7D0A092E7374317B6F7061
          636974793A302E353B7D0A3C2F7374796C653E0A3C672069643D22416464223E
          0A093C7061746820636C6173733D22477265656E2220643D224D32372C313468
          2D39563563302D302E352D302E352D312D312D31682D32632D302E352C302D31
          2C302E352D312C3176394835632D302E352C302D312C302E352D312C31763263
          302C302E352C302E352C312C312C31683976390A090963302C302E352C302E35
          2C312C312C31683263302E352C302C312D302E352C312D31762D39683963302E
          352C302C312D302E352C312D31762D324332382C31342E352C32372E352C3134
          2C32372C31347A222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_add.svg'
      end>
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 56
    Top = 80
    object actAggiungiItem: TAction
      Caption = 'Aggiungi'
      ImageIndex = 38
      OnExecute = actAggiungiItemExecute
    end
    object actRimuoviItem: TAction
      Caption = 'Rimuovi'
      ImageIndex = 46
      OnExecute = actRimuoviItemExecute
    end
    object AggiungiGroup: TAction
      Caption = 'Aggiungi Group'
      Hint = 'Aggiungi Group'
      ImageIndex = 49
      OnExecute = AggiungiGroupExecute
    end
    object AggiungiButton: TAction
      Caption = 'Aggiungi Button'
      Hint = 'Aggiungi Button'
      ImageIndex = 38
    end
    object AggiungiLineBreak: TAction
      Caption = 'Aggiungi LineBreak'
      Hint = 'Aggiungi LineBreak'
      ImageIndex = 105
      OnExecute = AggiungiLineBreakExecute
    end
    object AggiungiSeparatore: TAction
      Caption = 'Aggiungi Separatore'
      Hint = 'Aggiungi Separatore'
      ImageIndex = 52
      OnExecute = AggiungiSeparatoreExecute
    end
    object MostraCampi: TAction
      Caption = 'Mostra'
      ImageIndex = 477
      ShortCut = 16461
      OnExecute = MostraCampiExecute
    end
    object NascondiCampi: TAction
      Caption = 'Nascondi'
      ImageIndex = 443
      ShortCut = 16462
      OnExecute = NascondiCampiExecute
    end
    object SpostaCampi: TAction
      Caption = 'Sposta'
      ImageIndex = 160
      OnExecute = SpostaCampiExecute
    end
    object Raggruppa: TAction
      Caption = 'Raggruppa'
      ImageIndex = 152
      ShortCut = 16466
      OnExecute = RaggruppaExecute
    end
    object Separa: TAction
      Caption = 'Separa'
      ImageIndex = 175
      OnExecute = SeparaExecute
    end
    object ProperitaCard: TAction
      Caption = 'Properit'#224' Card'
      ImageIndex = 16
      OnExecute = ProperitaCardExecute
    end
    object Adatta: TAction
      Caption = 'Adatta'
      ImageIndex = 526
      OnExecute = AdattaExecute
    end
    object ResetOrdineCampi: TAction
      Caption = 'Reset'
      Hint = 'reset ordine campi'
      ImageIndex = 345
      OnExecute = ResetOrdineCampiExecute
    end
    object EditCampi: TAction
      Caption = 'Campi...'
      ImageIndex = 199
      OnExecute = EditCampiExecute
    end
    object RipristinaEtichette: TAction
      Caption = 'Etichette'
      Hint = 'Ripristina le etichette vuote dei controlli; ricalcola i domini senza etichetta'
      ImageIndex = 345
      OnExecute = RipristinaEtichetteExecute
    end
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    ImageOptions.Images = dx.Immagini
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 136
    Top = 80
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      22
      0)
    object dxBarManagerBar1: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      BorderStyle = bbsNone
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 627
      FloatTop = 200
      FloatClientWidth = 115
      FloatClientHeight = 164
      ItemLinks = <
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
          ItemName = 'dxBarButton13'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton8'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton7'
        end
        item
          Visible = True
          ItemName = 'dxBarButton4'
        end
        item
          Visible = True
          ItemName = 'dxBarButton6'
        end
        item
          Visible = True
          ItemName = 'dxBarButton9'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton14'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton17'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton10'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton12'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton18'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton15'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton1'
        end>
      NotDocking = [dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = True
    end
    object dxBarButton3: TdxBarButton
      Action = MostraCampi
      Category = 0
    end
    object dxBarButton13: TdxBarButton
      Action = NascondiCampi
      Category = 0
    end
    object cxBarEditItemSposta: TcxBarEditItem
      Caption = 'Sposta'
      Category = 0
      Hint = 'Sposta'
      Visible = ivAlways
      PropertiesClassName = 'TcxPopupEditProperties'
      Properties.PopupControl = pnlSposta
      Properties.OnInitPopup = cxBarEditItemSpostaPropertiesInitPopup
    end
    object dxBarButton14: TdxBarButton
      Action = Raggruppa
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = actAggiungiItem
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = actRimuoviItem
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = AggiungiButton
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = AggiungiGroup
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = AggiungiLineBreak
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Action = AggiungiSeparatore
      Category = 0
    end
    object dxBarButton1: TdxBarButton
      Action = ProperitaCard
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = actRimuoviItem
      Category = 0
    end
    object dxBarButton10: TdxBarButton
      Action = Adatta
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = ResetOrdineCampi
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Action = ResetOrdineCampi
      Category = 0
    end
    object dxBarButton15: TdxBarButton
      Action = EditCampi
      Category = 0
    end
    object dxBarButton16: TdxBarButton
      Action = Separa
      Category = 0
    end
    object dxBarButton17: TdxBarButton
      Action = Separa
      Category = 0
    end
    object dxBarButton18: TdxBarButton
      Action = RipristinaEtichette
      Category = 0
    end
  end
  object popTree: TdxBarPopupMenu
    BarManager = dxBarManager
    Images = dx.Immagini
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton3'
      end
      item
        Visible = True
        ItemName = 'dxBarButton13'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'cxBarEditItemSposta'
      end
      item
        Visible = True
        ItemName = 'dxBarButton2'
      end
      item
        Visible = True
        ItemName = 'dxBarButton5'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton7'
      end
      item
        Visible = True
        ItemName = 'dxBarButton4'
      end
      item
        Visible = True
        ItemName = 'dxBarButton6'
      end
      item
        Visible = True
        ItemName = 'dxBarButton9'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton14'
      end
      item
        Visible = True
        ItemName = 'dxBarButton16'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton11'
      end
      item
        Visible = True
        ItemName = 'dxBarButton18'
      end>
    UseOwnFont = False
    Left = 216
    Top = 80
    PixelsPerInch = 96
  end
  object imageCtrlType: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 9437552
    ImageInfo = <
      item
        ImageClass = 'TBitmap'
        Image.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000130B0000130B0000000100000000000000000000FFFF
          FF00FF00FF00A3522800FDEDDD00FDF3E900FEF7F000FFFAF500FFFCF900FCEB
          D900FCEDDD00FDF0E200FEF4E90051515100FFFFFF0002020200020202000202
          0200020202000202020002020200020202000202020002020200020202000202
          0200020202000202020002020200020202000202020002030300030303000303
          030003030300020301000101010001030C000409030002030100010101000103
          06000D0A0300020301000101010001030D000D0D030002030100010101000103
          0800060503000203030003030300030303000303030002020200020202000202
          0200020202000202020002020200020202000202020002020200020202000202
          0200020202000202020002020200020202000202020002020200020202000202
          0200020202000202020002020200020202000202020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200000002000000
          0200000002000000020000000200000002000000020000000200020202020202
          0202020202020202020202020202020202020202020202020202020202020202
          0202020202020202020202020202020202020202020202020202020303030303
          03030303030303030302020301010101010101030C0B04090302020301010101
          01010103060D0D0A0302020301010101010101030D0D0D0D0302020301010101
          0101010308070605030202030303030303030303030303030302020202020202
          0202020202020202020202020202020202020202020202020202020202020202
          0202020202020202020202020202020202020202020202020202020202020202
          0202020202020202020202020202020202020202020202020202}
        MaskColor = clFuchsia
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D2253656C
          6563745461626C652220786D6C6E733D22687474703A2F2F7777772E77332E6F
          72672F323030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F
          2F7777772E77332E6F72672F313939392F786C696E6B2220783D22307078220A
          0920793D22307078222076696577426F783D2230203020333220333222207374
          796C653D22656E61626C652D6261636B67726F756E643A6E6577203020302033
          322033323B2220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E426C75657B66696C6C
          3A233131373744373B7D0A3C2F7374796C653E0A3C7061746820636C6173733D
          22426C75652220643D224D31302C31304832563468385631307A204D32302C34
          682D387636683856347A204D33302C34682D387636683856347A204D31302C31
          324832763668385631327A204D32302C3132682D38763668385631327A204D33
          302C3132682D38763668385631327A0A09204D31302C32304832763668385632
          307A204D32302C3230682D38763668385632307A204D33302C3230682D387636
          68385632307A222F3E0A3C2F7376673E0A}
        FileName = 'selecttable.svg'
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
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D2270656E63696C2D
          626F7822207472616E73666F726D3D227363616C6528312E3333333333332922
          3E0A093C7061746820643D224D31392C3341322C32203020302C312032312C35
          5631394332312C32302E31312032302E312C32312031392C3231483541322C32
          203020302C3120332C3139563541322C32203020302C3120352C334831394D31
          362E372C392E33354331362E39322C392E31342031362E39322C382E37392031
          362E372C382E35384C31352E34322C372E334331352E32312C372E3038203134
          2E38362C372E30382031342E36352C372E334C31332E36352C382E334C31352E
          372C31302E33354C31362E372C392E33354D372C31342E393456313748392E30
          364C31352E31322C31302E39344C31332E30362C382E38384C372C31342E3934
          5A2220636C6173733D22426C61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'pencil-box.svg'
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
          20747970653D22746578742F637373223E0A092E426C75657B66696C6C3A2331
          31373744373B7D0A3C2F7374796C653E0A3C672069643D226172726F775F736F
          727422207472616E73666F726D3D227363616C6528312E33333333333329223E
          0A093C7061746820643D224D362E323838323920342E32393332374C322E3239
          32353220382E32393332374C322E323039333820382E333837353243312E3930
          34353620382E373739393720312E393332353920392E333437313920322E3239
          33323720392E37303734384C322E333837353220392E373930363243322E3737
          3939372031302E3039353420332E33343731392031302E3036373420332E3730
          37343820392E37303637334C362E30303120372E34314C362E30303130312031
          392E303030374C362E30303737342031392E3131373343362E30363535203139
          2E3631343620362E34383831372032302E3030303720372E3030313031203230
          2E303030374C372E31313736332031392E3939333943372E3631343937203139
          2E3933363220382E30303130312031392E3531333520382E3030313031203139
          2E303030374C382E30303120372E3431374C31302E3239343420392E37303735
          374C31302E3338383620392E373930374331302E373831312031302E30393535
          2031312E333438332031302E303637342031312E3730383620392E3730363634
          4331322E3039383820392E33313538362031322E3039383420382E3638323720
          31312E3730373720382E32393234334C372E373032343220342E32393234334C
          372E363038313620342E323039333143372E323135373120332E393034353620
          362E363438353520332E393332363220362E323838323920342E32393332375A
          4D313720342E30303331374C31362E3838333420342E303039394331362E3338
          3620342E303637363720313620342E343930333420313620352E30303331374C
          31362031362E3538334C31332E373036382031342E323932354C31332E363132
          352031342E323039344331332E323230312031332E393034352031322E363532
          392031332E393332352031322E323932362031342E323933324331312E393032
          322031342E363833392031312E393032352031352E333137312031322E323933
          322031352E373037344C31362E3239372031392E373037344C31362E33393132
          2031392E373930354331362E373833372032302E303935342031372E33353039
          2032302E303637342031372E373131322031392E373036374C32312E37303734
          2031352E373036374C32312E373930362031352E363132354332322E30393534
          2031352E32322032322E303637342031342E363532382032312E373036382031
          342E323932354C32312E363132352031342E323039344332312E323230312031
          332E393034352032302E363532392031332E393332352032302E323932362031
          342E323933324C31382031362E3538374C313820352E30303331374C31372E39
          39333320342E38383635354331372E3933353520342E33383932312031372E35
          31323820342E303033313720313720342E30303331375A2220636C6173733D22
          426C756522202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'arrow_sort.svg'
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
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D2270656E63696C2D
          626F7822207472616E73666F726D3D227363616C6528312E3333333333332922
          3E0A093C7061746820643D224D31392C3341322C32203020302C312032312C35
          5631394332312C32302E31312032302E312C32312031392C3231483541322C32
          203020302C3120332C3139563541322C32203020302C3120352C334831394D31
          362E372C392E33354331362E39322C392E31342031362E39322C382E37392031
          362E372C382E35384C31352E34322C372E334331352E32312C372E3038203134
          2E38362C372E30382031342E36352C372E334C31332E36352C382E334C31352E
          372C31302E33354C31362E372C392E33354D372C31342E393456313748392E30
          364C31352E31322C31302E39344C31332E30362C382E38384C372C31342E3934
          5A2220636C6173733D22426C61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'pencil-box.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E426C61636B7B66696C6C3A233732373237323B7D0A092E477265656E7B6669
          6C6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B
          7D0A092E7374307B6F7061636974793A302E37353B7D0A092E7374317B6F7061
          636974793A302E353B7D0A3C2F7374796C653E0A3C672069643D224564697422
          3E0A093C7061746820636C6173733D22426C75652220643D224D32372E362C38
          2E326C2D332E382D332E38632D302E352D302E352D312E342D302E352D312E39
          2C306C2D322E352C322E356C352E382C352E386C322E352D322E354332382E31
          2C392E362C32382E312C382E382C32372E362C382E327A222F3E0A093C706F6C
          79676F6E20636C6173733D22426C75652220706F696E74733D22342C32382039
          2E382C323820342C32322E322009222F3E0A093C7265637420783D22352E3822
          20793D2231332E3422207472616E73666F726D3D226D617472697828302E3730
          37202D302E3730373220302E3730373220302E373037202D382E303732312031
          352E34303438292220636C6173733D22426C7565222077696474683D2231372E
          3622206865696768743D22382E32222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_edit.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E426C75657B66696C6C3A233131
          373744373B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A09
          2E477265656E7B66696C6C3A233033394332333B7D0A092E477265656E7B6669
          6C6C3A233033394332333B7D0A092E5265647B66696C6C3A234431314331433B
          7D0A092E7374307B6F7061636974793A302E37353B7D0A092E7374317B6F7061
          636974793A302E353B7D0A3C2F7374796C653E0A3C672069643D22436865636B
          223E0A093C706F6C79676F6E20636C6173733D22477265656E2220706F696E74
          733D2232372C352031312C323120352C313520322C31382031312C3237203330
          2C382009222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'actions_check.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E312E302C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D224C6179
          65725F312220786D6C6E733D22687474703A2F2F7777772E77332E6F72672F32
          3030302F7376672220786D6C6E733A786C696E6B3D22687474703A2F2F777777
          2E77332E6F72672F313939392F786C696E6B2220783D223070782220793D2230
          7078220A092076696577426F783D2230203020333220333222207374796C653D
          22656E61626C652D6261636B67726F756E643A6E657720302030203332203332
          3B2220786D6C3A73706163653D227072657365727665223E0A3C7374796C6520
          747970653D22746578742F637373223E0A092E59656C6C6F777B66696C6C3A23
          4646423131353B7D0A092E5265647B66696C6C3A234431314331433B7D0A092E
          426C61636B7B66696C6C3A233732373237323B7D0A092E426C75657B66696C6C
          3A233131373744373B7D0A092E57686974657B66696C6C3A234646464646463B
          7D0A092E477265656E7B66696C6C3A233033394332333B7D0A092E7374307B6F
          7061636974793A302E37353B7D0A092E7374317B6F7061636974793A302E353B
          7D0A092E7374327B6F7061636974793A302E32353B7D0A092E7374337B66696C
          6C3A234646423131353B7D0A3C2F7374796C653E0A3C673E0A3C2F673E0A3C67
          2069643D2247726964223E0A093C6720636C6173733D22737431223E0A09093C
          7061746820636C6173733D22426C61636B2220643D224D32322C313268387636
          682D385631327A204D31322C313276366838762D364831327A204D31302C3138
          762D36483276364831307A204D32322C32366838762D36682D385632367A204D
          31322C323076366838762D364831327A204D31302C3236762D3648320A090909
          76364831307A222F3E0A093C2F673E0A093C7265637420783D22322220793D22
          342220636C6173733D22426C7565222077696474683D22323822206865696768
          743D2236222F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'grid.svg'
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
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D22726164696F2220
          7472616E73666F726D3D227363616C6528312E33333333333329223E0A093C70
          61746820643D224D32302C3641322C32203020302C312032322C385632304132
          2C32203020302C312032302C3232483441322C32203020302C3120322C323056
          3843322C372E313520322E35332C362E343220332E32382C362E31334C31352E
          37312C314C31362E34372C322E38334C382E38332C364832304D32302C384834
          56313248313656313048313856313248323056384D372C313441332C33203020
          302C3020342C313741332C33203020302C3020372C323041332C33203020302C
          302031302C313741332C33203020302C3020372C31345A2220636C6173733D22
          426C61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'radio.svg'
      end>
  end
  object CheckImages: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 13631856
    ImageInfo = <
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D225F7833
          345F5F547261666669635F4C69676874732220786D6C6E733D22687474703A2F
          2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C696E
          6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B22
          0A0920783D223070782220793D22307078222076696577426F783D2230203020
          31362031362220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E5265647B66696C6C3A
          234431314331433B7D0A3C2F7374796C653E0A3C636972636C6520636C617373
          3D22526564222063783D2238222063793D22382220723D2237222F3E0A3C2F73
          76673E0A}
        FileName = 'circle_red.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D225F7833
          345F5F547261666669635F4C69676874732220786D6C6E733D22687474703A2F
          2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C696E
          6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B22
          0A0920783D223070782220793D22307078222076696577426F783D2230203020
          31362031362220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E5265647B66696C6C3A
          234431314331433B7D0A3C2F7374796C653E0A3C636972636C6520636C617373
          3D22526564222063783D2238222063793D22382220723D2237222F3E0A3C2F73
          76673E0A}
        FileName = 'circle_red.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C212D2D2047656E657261746F723A2041646F626520496C6C
          7573747261746F722032312E302E322C20535647204578706F727420506C7567
          2D496E202E205356472056657273696F6E3A20362E3030204275696C64203029
          20202D2D3E0A3C7376672076657273696F6E3D22312E31222069643D225F7833
          345F5F547261666669635F4C69676874732220786D6C6E733D22687474703A2F
          2F7777772E77332E6F72672F323030302F7376672220786D6C6E733A786C696E
          6B3D22687474703A2F2F7777772E77332E6F72672F313939392F786C696E6B22
          0A0920783D223070782220793D22307078222076696577426F783D2230203020
          31362031362220786D6C3A73706163653D227072657365727665223E0A3C7374
          796C6520747970653D22746578742F637373223E0A092E5265647B66696C6C3A
          234431314331433B7D0A3C2F7374796C653E0A3C636972636C6520636C617373
          3D22526564222063783D2238222063793D22382220723D2237222F3E0A3C2F73
          76673E0A}
        FileName = 'circle_red.svg'
      end>
  end
end
