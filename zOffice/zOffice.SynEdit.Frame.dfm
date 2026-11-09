object zViewerSynEditFrame: TzViewerSynEditFrame
  Left = 0
  Top = 0
  Width = 663
  Height = 559
  TabOrder = 0
  object PanelEditor: TPanel
    Left = 0
    Top = 24
    Width = 663
    Height = 535
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object StatusBar: TdxStatusBar
      Left = 0
      Top = 515
      Width = 663
      Height = 20
      Panels = <
        item
          PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
          Width = 66
        end
        item
          PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
          Width = 75
        end
        item
          PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
          Width = 90
        end
        item
          PanelStyleClassName = 'TdxStatusBarKeyboardStatePanelStyle'
          PanelStyle.CapsLockKeyAppearance.ActiveCaption = 'CAPS'
          PanelStyle.CapsLockKeyAppearance.InactiveCaption = 'CAPS'
          PanelStyle.NumLockKeyAppearance.ActiveCaption = 'NUM'
          PanelStyle.NumLockKeyAppearance.InactiveCaption = 'NUM'
          PanelStyle.ScrollLockKeyAppearance.ActiveCaption = 'SCRL'
          PanelStyle.ScrollLockKeyAppearance.InactiveCaption = 'SCRL'
          PanelStyle.InsertKeyAppearance.ActiveCaption = 'OVR'
          PanelStyle.InsertKeyAppearance.InactiveCaption = 'INS'
          Width = 130
        end
        item
          PanelStyleClassName = 'TdxStatusBarStateIndicatorPanelStyle'
          PanelStyle.Indicators = <>
        end>
      SizeGrip = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Editor: TSynEdit
      Left = 0
      Top = 0
      Width = 646
      Height = 498
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      Font.Quality = fqClearTypeNatural
      TabOrder = 0
      CodeFolding.ShowCollapsedLine = True
      UseCodeFolding = False
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      Gutter.Font.Quality = fqClearTypeNatural
      Gutter.ShowLineNumbers = True
      Gutter.Bands = <
        item
          Kind = gbkMarks
          Width = 13
        end
        item
          Kind = gbkLineNumbers
        end
        item
          Kind = gbkFold
        end
        item
          Kind = gbkTrackChanges
        end
        item
          Kind = gbkMargin
          Width = 3
        end>
      ReadOnly = True
      ScrollBars = ssNone
      ScrollbarAnnotations = <>
      SearchEngine = SynEditRegexSearch
      OnStatusChange = EditorStatusChange
      RemovedKeystrokes = <
        item
          Command = ecContextHelp
          ShortCut = 112
        end>
      AddedKeystrokes = <
        item
          Command = ecContextHelp
          ShortCut = 16496
        end>
    end
    object VScrollBar: TcxScrollBar
      Left = 646
      Top = 0
      Width = 17
      Height = 498
      Align = alRight
      Ctl3D = True
      Kind = sbVertical
      LargeChange = 3
      PageSize = 0
      ParentCtl3D = False
      OnScroll = VScrollBarScroll
    end
    object HScrollBar: TcxScrollBar
      AlignWithMargins = True
      Left = 0
      Top = 498
      Width = 646
      Height = 17
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 17
      Margins.Bottom = 0
      Align = alBottom
      Ctl3D = True
      PageSize = 0
      ParentCtl3D = False
      OnScroll = HScrollBarScroll
    end
  end
  object SynEditOptionsDialog: TSynEditOptionsDialog
    UseExtendedStrings = False
    Left = 336
    Top = 40
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 72
    Top = 43
    object Importa: TdxFileOpen
      Caption = 'Importa'
      Dialog.Options = [ofOverwritePrompt, ofEnableSizing]
      Hint = 'apri un file esistente'
      ImageIndex = 238
      BeforeExecute = ImportaBeforeExecute
      OnAccept = ImportaAccept
      OnUpdate = ImportaUpdate
    end
    object SalvaSuFile: TdxFileSaveAs
      Caption = 'Salva su File'
      Dialog.DefaultExt = '*.SQL'
      Dialog.Filter = 'SQL|*.sql|Tutti|*.*'
      Hint = 'Salva su File'
      ImageIndex = 92
      ShortCut = 16467
      BeforeExecute = SalvaSuFileBeforeExecute
      OnAccept = SalvaSuFileAccept
    end
    object Apri: TAction
      Caption = 'Apri'
      ImageIndex = 36
      OnExecute = ApriExecute
    end
    object Stampa: TAction
      Caption = 'Stampa'
      ImageIndex = 208
      OnExecute = StampaExecute
    end
    object actCopia: TEditCopy
      Caption = 'Copia'
      Hint = 'copia'
      ImageIndex = 62
      ShortCut = 16451
    end
    object actSelezionaTutto: TEditSelectAll
      Caption = 'Seleziona Tutto'
      Hint = 'seleziona tutto'
      ImageIndex = 193
      ShortCut = 16449
    end
    object actTrova: TAction
      Caption = 'Trova...'
      Hint = 'trova'
      ImageIndex = 189
      ShortCut = 16454
      OnExecute = actTrovaExecute
    end
    object actOpzioniEditor: TAction
      Caption = 'Opzioni Editor'
      Hint = 'Opzioni Editor'
      ImageIndex = 528
      Visible = False
      OnExecute = actOpzioniEditorExecute
    end
    object Formatta: TAction
      Caption = 'Formatta'
      ImageIndex = 336
      ShortCut = 16452
      OnExecute = FormattaExecute
      OnUpdate = FormattaUpdate
    end
  end
  object FindDialog: TFindDialog
    OnFind = DoFindText
    Left = 200
    Top = 170
  end
  object dxBarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Predefinito'
      'PopupMenu')
    Categories.ItemsVisibles = (
      2
      2)
    Categories.Visibles = (
      True
      True)
    ImageOptions.Images = dx.Immagini
    ImageOptions.UseLargeImagesForLargeIcons = True
    PopupMenuLinks = <
      item
        Control = Editor
        PopupMenu = dxBarPopupMenu
      end>
    UseSystemFont = True
    Left = 200
    Top = 40
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
      AllowReset = False
      BorderStyle = bbsNone
      Caption = 'Costume1'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 673
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarButton5'
        end
        item
          Visible = True
          ItemName = 'dxBarButton3'
        end
        item
          Visible = True
          ItemName = 'dxBarButton4'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton7'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton1'
        end>
      NotDocking = [dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      SizeGrip = False
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object dxBarButton5: TdxBarButton
      Action = SalvaSuFile
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = actCopia
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Caption = 'Format SQL'
      Category = 0
      Visible = ivAlways
      ImageIndex = -1
      ShortCut = 16452
    end
    object dxBarButton13: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton14: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton1: TdxBarButton
      Action = actTrova
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = Importa
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Action = Apri
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = Stampa
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = Importa
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = SalvaSuFile
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Action = Apri
      Category = 0
    end
    object dxBarButton10: TdxBarButton
      Action = Stampa
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = Formatta
      Category = 0
    end
    object Copy1: TdxBarButton
      Action = actCopia
      Category = 1
    end
    object SelectAll1: TdxBarButton
      Action = actSelezionaTutto
      Category = 1
    end
    object Find1: TdxBarButton
      Action = actTrova
      Category = 1
    end
    object EditorOptions1: TdxBarButton
      Action = actOpzioniEditor
      Category = 1
    end
  end
  object dxBarPopupMenu: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton6'
      end
      item
        Visible = True
        ItemName = 'dxBarButton8'
      end
      item
        Visible = True
        ItemName = 'dxBarButton9'
      end
      item
        Visible = True
        ItemName = 'dxBarButton10'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'Copy1'
      end
      item
        Visible = True
        ItemName = 'SelectAll1'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'Find1'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton11'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'EditorOptions1'
      end>
    UseOwnFont = False
    Left = 200
    Top = 105
    PixelsPerInch = 96
  end
  object SynXMLSyn: TSynXMLSyn
    Brackets = '<>()[]'
    WantBracesParsed = False
    Left = 312
    Top = 312
  end
  object SynJSONSyn: TSynJSONSyn
    Left = 200
    Top = 312
  end
  object SynEditPrint: TSynEditPrint
    Copies = 1
    Header.DefaultFont.Charset = DEFAULT_CHARSET
    Header.DefaultFont.Color = clBlack
    Header.DefaultFont.Height = -13
    Header.DefaultFont.Name = 'Arial'
    Header.DefaultFont.Style = []
    Footer.DefaultFont.Charset = DEFAULT_CHARSET
    Footer.DefaultFont.Color = clBlack
    Footer.DefaultFont.Height = -13
    Footer.DefaultFont.Name = 'Arial'
    Footer.DefaultFont.Style = []
    Margins.Left = 25.000000000000000000
    Margins.Right = 15.000000000000000000
    Margins.Top = 25.000000000000000000
    Margins.Bottom = 25.000000000000000000
    Margins.Header = 15.000000000000000000
    Margins.Footer = 15.000000000000000000
    Margins.LeftHFTextIndent = 2.000000000000000000
    Margins.RightHFTextIndent = 2.000000000000000000
    Margins.HFInternalMargin = 0.500000000000000000
    Margins.MirrorMargins = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    TabWidth = 8
    Color = clWhite
    Left = 200
    Top = 246
  end
  object SynEditRegexSearch: TSynEditRegexSearch
    Left = 336
    Top = 105
  end
  object PrintDialog: TPrintDialog
    Left = 313
    Top = 247
  end
end
