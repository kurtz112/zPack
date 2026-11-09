object zTreeMenu: TzTreeMenu
  Left = 0
  Top = 0
  Width = 251
  Height = 450
  TabOrder = 0
  object tree: TcxTreeList
    Left = 0
    Top = 0
    Width = 251
    Height = 450
    Align = alClient
    Bands = <
      item
      end>
    FindPanel.DisplayMode = fpdmAlways
    FindPanel.InfoText = 'cerca...'
    FindPanel.ShowClearButton = False
    FindPanel.ShowCloseButton = False
    FindPanel.ShowFindButton = False
    Images = TreeImages
    OptionsBehavior.ImmediateEditor = False
    OptionsBehavior.CopyCaptionsToClipboard = False
    OptionsBehavior.IncSearch = True
    OptionsBehavior.IncSearchItem = treeColumn
    OptionsData.Editing = False
    OptionsData.Deleting = False
    OptionsSelection.InvertSelect = False
    OptionsView.CellEndEllipsis = True
    OptionsView.Headers = False
    OptionsView.ShowRoot = False
    PopupMenu = PopupMenu
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 0
    OnCanSelectNode = treeCanSelectNode
    OnClick = treeClick
    OnDblClick = treeDblClick
    OnKeyUp = treeKeyUp
    OnMouseEnter = treeMouseEnter
    OnMouseLeave = treeMouseLeave
    object treeColumn: TcxTreeListColumn
      Options.CellEndEllipsis = False
      Options.Editing = False
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
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
    ImageOptions.LargeImages = dx.Immagini
    PopupMenuLinks = <
      item
        PopupMenu = PopupMenu
      end>
    UseSystemFont = True
    Left = 120
    Top = 224
    PixelsPerInch = 96
    object dxBarButton1: TdxBarButton
      Action = actRename
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = Comprimi
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Action = Espandi
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = actGroup
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = actMoveUp
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Caption = 'Nascondi'
      Category = 0
      Visible = ivNever
      ImageIndex = 443
    end
    object dxBarButton7: TdxBarButton
      Action = actMoveDown
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = actSalva
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Action = EspandiAutomaticamente
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton10: TdxBarButton
      Action = Proprieta
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = CopiaTitoli
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Action = Markdown
      Category = 0
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 120
    Top = 160
    object Espandi: TAction
      Caption = 'Espandi'
      ImageIndex = 144
      ShortCut = 16571
      OnExecute = EspandiExecute
    end
    object Comprimi: TAction
      Caption = 'Comprimi'
      ImageIndex = 145
      ShortCut = 16495
      OnExecute = ComprimiExecute
    end
    object EspandiAutomaticamente: TAction
      Caption = 'Espandi Automaticamente'
      ImageIndex = 144
      OnExecute = EspandiAutomaticamenteExecute
      OnUpdate = EspandiAutomaticamenteUpdate
    end
    object actRename: TAction
      Caption = 'Titolo'
      ImageIndex = 356
      OnExecute = actRenameExecute
      OnUpdate = VisibleIfAdmin
    end
    object CopiaTitoli: TAction
      Caption = 'Copia Titoli'
      ImageIndex = 62
      OnExecute = CopiaTitoliExecute
      OnUpdate = VisibleIfAdmin
    end
    object Markdown: TAction
      Caption = 'Markdown'
      ImageIndex = 27
      OnExecute = MarkdownExecute
      OnUpdate = VisibleIfAdmin
    end
    object actGroup: TAction
      Caption = 'Gruppo'
      ImageIndex = 152
      OnExecute = actGroupExecute
      OnUpdate = VisibleIfAdmin
    end
    object actMoveUp: TAction
      Caption = 'Sposta In Alto'
      ImageIndex = 160
      OnExecute = actMoveUpExecute
      OnUpdate = VisibleIfAdmin
    end
    object actMoveDown: TAction
      Caption = 'Sposta in Basso'
      ImageIndex = 159
      OnExecute = actMoveDownExecute
      OnUpdate = VisibleIfAdmin
    end
    object actSalva: TAction
      Caption = 'Salva'
      ImageIndex = 92
      OnExecute = actSalvaExecute
      OnUpdate = VisibleIfAdmin
    end
    object Proprieta: TAction
      Caption = 'Propriet'#224
      ImageIndex = 16
      OnExecute = ProprietaExecute
      OnUpdate = VisibleIfAdmin
    end
  end
  object PopupMenu: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton3'
      end
      item
        Visible = True
        ItemName = 'dxBarButton2'
      end
      item
        Visible = True
        ItemName = 'dxBarButton9'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton5'
      end
      item
        Visible = True
        ItemName = 'dxBarButton7'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton1'
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
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton11'
      end
      item
        Visible = True
        ItemName = 'dxBarButton12'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton8'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton10'
      end>
    UseOwnFont = False
    Left = 120
    Top = 288
    PixelsPerInch = 96
  end
  object TreeImages: TcxImageList
    SourceDPI = 96
    FormatVersion = 1
    DesignInfo = 6815784
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
          20747970653D22746578742F637373223E0A092E59656C6C6F777B66696C6C3A
          234646423131353B7D0A3C2F7374796C653E0A3C672069643D22666F6C646572
          2D6F75746C696E6522207472616E73666F726D3D227363616C6528312E333333
          33333329223E0A093C7061746820643D224D32302C3138483456384832304D32
          302C364831324C31302C34483443322E38392C3420322C342E383920322C3656
          313841322C32203020302C3020342C323048323041322C32203020302C302032
          322C313856384332322C362E38392032312E312C362032302C365A2220636C61
          73733D2259656C6C6F7722202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'folder-outline.svg'
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
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D2266696C652D6D75
          6C7469706C652D6F75746C696E6522207472616E73666F726D3D227363616C65
          28312E33333333333329223E0A093C7061746820643D224D3136203048384336
          2E3920302036202E392036203256313843362031392E3120362E392032302038
          2032304832304332312E312032302032322031392E3120323220313856364C31
          3620304D32302031384838563248313556374832305631384D34203456323248
          3230563234483443322E3920323420322032332E312032203232563448345A22
          20636C6173733D22426C61636B22202F3E0A3C2F673E0A3C2F7376673E0A}
        FileName = 'file-multiple-outline.svg'
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
          3732373237323B7D0A3C2F7374796C653E0A3C672069643D2266696C652D6F75
          746C696E6522207472616E73666F726D3D227363616C6528312E333333333333
          29223E0A093C7061746820643D224D31342C32483641322C32203020302C3020
          342C3456323041322C32203020302C3020362C323248313841322C3220302030
          2C302032302C323056384C31342C324D31382C32304836563448313356394831
          385632305A2220636C6173733D22426C61636B22202F3E0A3C2F673E0A3C2F73
          76673E0A}
        FileName = 'file-outline.svg'
      end
      item
        ImageClass = 'TdxSmartImage'
        Image.Data = {
          3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227574
          662D38223F3E0A3C7376672076657273696F6E3D22312E312220786D6C6E733D
          22687474703A2F2F7777772E77332E6F72672F323030302F7376672220766965
          77426F783D22302030203332203332223E0A3C7374796C6520747970653D2274
          6578742F637373223E0A092E426C61636B7B66696C6C3A233732373237323B7D
          0A092E426C75657B66696C6C3A233131373744373B7D0A092E477265656E7B66
          696C6C3A233033394332333B7D0A092E5265647B66696C6C3A23443131433143
          3B7D0A092E59656C6C6F777B66696C6C3A234646423131353B7D0A092E737431
          7B6F7061636974793A302E353B7D0A3C2F7374796C653E0A3C7061746820636C
          6173733D22426C61636B2220643D224D32302E332C386C2D362D364832306C38
          2C386C2D382C38682D352E376C362D36483136632D322E322C302D342C312E38
          2D342C34763132483856313663302D342E342C332E362D382C382D384832302E
          337A222F3E0A3C2F7376673E0A}
        FileName = 'nodo_selezionato.svg'
      end>
  end
end
