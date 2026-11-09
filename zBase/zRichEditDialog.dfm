object zRichEditForm: TzRichEditForm
  Left = 0
  Top = 0
  ClientHeight = 376
  ClientWidth = 812
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cxRichEdit: TcxRichEdit
    AlignWithMargins = True
    Left = 3
    Top = 29
    Align = alClient
    Properties.OnSelectionChange = cxRichEditPropertiesSelectionChange
    TabOrder = 0
    Height = 314
    Width = 806
  end
  object OkCancel: TOkCancel
    Left = 0
    Top = 346
    Width = 812
    Height = 30
    Align = alBottom
    TabOrder = 1
     
    DefaultOk = False
    DefaultCancel = False
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
    Left = 168
    Top = 160
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      26
      0)
    object dxBarManagerBarToolbar: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'Toolbar'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 669
      FloatTop = 8
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton8'
        end
        item
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton3'
        end
        item
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton4'
        end
        item
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton5'
        end
        item
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton6'
        end
        item
          Visible = True
          ItemName = 'dxBarButton7'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'cxBarEditItemFontName'
        end
        item
          Visible = True
          ItemName = 'cxBarEditItemFontSize'
        end
        item
          Visible = True
          ItemName = 'cxBarEditItemFontColor'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton9'
        end
        item
          Visible = True
          ItemName = 'dxBarButton10'
        end
        item
          Visible = True
          ItemName = 'dxBarButton12'
        end
        item
          Visible = True
          ItemName = 'dxBarButton13'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton14'
        end
        item
          Visible = True
          ItemName = 'dxBarButton21'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton16'
        end
        item
          Visible = True
          ItemName = 'dxBarButton17'
        end
        item
          Visible = True
          ItemName = 'dxBarButton18'
        end
        item
          Visible = True
          ItemName = 'dxBarButton19'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          Visible = True
          ItemName = 'dxBarButton22'
        end>
      NotDocking = [dsNone, dsLeft, dsRight, dsBottom]
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
      Action = FileOpen
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = FileSaveAs
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Action = EditCut
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = EditCopy
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = EditPaste
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = EditDelete
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Action = EditUndo
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = EditSelectAll
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = EditSelectAll
      Category = 0
    end
    object dxBarButton9: TdxBarButton
      Action = FormatRichEditBold
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton10: TdxBarButton
      Action = FormatRichEditItalic
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton12: TdxBarButton
      Action = FormatRichEditUnderline
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton13: TdxBarButton
      Action = FormatRichEditStrikeOut
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton14: TdxBarButton
      Action = FormatRichEditBullets
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton15: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton16: TdxBarButton
      Action = FormatRichEditAlignLeft
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton17: TdxBarButton
      Action = FormatRichEditAlignCenter
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton18: TdxBarButton
      Action = FormatRichEditAlignRight
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarEdit1: TdxBarEdit
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
    end
    object cxBarEditItemFontColor: TcxBarEditItem
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
      PropertiesClassName = 'TdxColorEditProperties'
      Properties.ImmediatePost = True
      Properties.ColorPalette = cpExtended
      Properties.OnCloseUp = cxBarEditItemFontColorPropertiesCloseUp
    end
    object cxBarEditItemFontName: TcxBarEditItem
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
      PropertiesClassName = 'TcxFontNameComboBoxProperties'
      Properties.DropDownSizeable = True
      Properties.ImmediatePost = True
      Properties.OnEditValueChanged = cxBarEditItemFontNamePropertiesEditValueChanged
    end
    object cxBarEditItemFontSize: TcxBarEditItem
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
      Width = 50
      PropertiesClassName = 'TcxSpinEditProperties'
      Properties.ImmediatePost = True
      Properties.OnEditValueChanged = cxBarEditItemFontSizePropertiesEditValueChanged
    end
    object dxBarButton19: TdxBarButton
      Action = Justify
      Category = 0
    end
    object dxBarButton20: TdxBarButton
      Action = Numerazione
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton21: TdxBarButton
      Action = Numerazione
      Category = 0
    end
    object dxBarButton22: TdxBarButton
      Action = Paragrafo
      Category = 0
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 168
    Top = 48
    object FileOpen: TdxFileOpen
      Caption = 'Apri'
      Dialog.DefaultExt = '*.rtf'
      Dialog.Filter = 'RTF|*.rtf|Testo|*.txt|Tutti|*.*'
      ImageIndex = 36
      ShortCut = 16463
      OnAccept = FileOpenAccept
    end
    object FileSaveAs: TdxFileSaveAs
      Caption = 'Salva'
      Dialog.DefaultExt = '*.rtf'
      Dialog.Filter = 'RTF|*.rtf|Testo|*.txt|Tutti|*.*'
      ImageIndex = 92
      OnAccept = FileSaveAsAccept
    end
    object EditUndo: TAction
      Caption = 'Annulla'
      ImageIndex = 54
      ShortCut = 16474
      OnExecute = EditUndoExecute
    end
    object EditCut: TAction
      Caption = 'Taglia'
      ImageIndex = 65
      ShortCut = 16472
      OnExecute = EditCutExecute
    end
    object EditCopy: TAction
      Caption = 'Copia'
      ImageIndex = 64
      ShortCut = 16451
      OnExecute = EditCopyExecute
    end
    object EditPaste: TAction
      Caption = 'Incolla'
      ImageIndex = 85
      ShortCut = 16470
      OnExecute = EditPasteExecute
    end
    object EditDelete: TAction
      Caption = 'Elimina'
      ImageIndex = 66
      ShortCut = 46
      OnExecute = EditDeleteExecute
    end
    object EditSelectAll: TAction
      Caption = 'Seleziona Tutto'
      ImageIndex = 193
      ShortCut = 16449
      OnExecute = EditSelectAllExecute
    end
    object FormatRichEditBold: TRichEditBold
      Category = 'Format'
      AutoCheck = True
      Caption = 'Grassetto'
      ImageIndex = 324
      ShortCut = 16450
      OnUpdate = FormatRichEditBoldUpdate
    end
    object FormatRichEditItalic: TRichEditItalic
      Category = 'Format'
      AutoCheck = True
      Caption = 'Corsivo'
      ImageIndex = 339
      ShortCut = 16457
      OnUpdate = FormatRichEditItalicUpdate
    end
    object FormatRichEditUnderline: TRichEditUnderline
      Category = 'Format'
      AutoCheck = True
      Caption = 'Sottolineato'
      ImageIndex = 358
      ShortCut = 16469
      OnUpdate = FormatRichEditUnderlineUpdate
    end
    object FormatRichEditStrikeOut: TRichEditStrikeOut
      Category = 'Format'
      AutoCheck = True
      Caption = 'Barrato'
      ImageIndex = 347
      OnUpdate = FormatRichEditStrikeOutUpdate
    end
    object FormatRichEditBullets: TRichEditBullets
      Category = 'Format'
      AutoCheck = True
      Caption = 'Elenco Puntato'
      ImageIndex = 343
      OnUpdate = FormatRichEditBulletsUpdate
    end
    object FormatRichEditAlignLeft: TRichEditAlignLeft
      Category = 'Format'
      AutoCheck = True
      Caption = 'Allinea Sinistra'
      ImageIndex = 315
      OnUpdate = FormatRichEditAlignLeftUpdate
    end
    object FormatRichEditAlignRight: TRichEditAlignRight
      Category = 'Format'
      AutoCheck = True
      Caption = 'Allinea Destra'
      ImageIndex = 319
      OnUpdate = FormatRichEditAlignRightUpdate
    end
    object FormatRichEditAlignCenter: TRichEditAlignCenter
      Category = 'Format'
      AutoCheck = True
      Caption = 'Allinea Centro'
      ImageIndex = 312
      OnUpdate = FormatRichEditAlignCenterUpdate
    end
    object Justify: TAction
      Category = 'Format'
      Caption = 'Justify'
      ImageIndex = 425
      OnExecute = JustifyExecute
      OnUpdate = JustifyUpdate
    end
    object Numerazione: TAction
      Category = 'Format'
      Caption = 'Numerazione'
      ImageIndex = 25
      OnExecute = NumerazioneExecute
      OnUpdate = NumerazioneUpdate
    end
    object Paragrafo: TAction
      Category = 'Format'
      Caption = 'Paragrafo'
      ImageIndex = 342
      OnExecute = ParagrafoExecute
    end
  end
  object dxBarPopupMenu: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton1'
      end
      item
        Visible = True
        ItemName = 'dxBarButton2'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton8'
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
        Visible = True
        ItemName = 'dxBarButton5'
      end
      item
        Visible = True
        ItemName = 'dxBarButton6'
      end
      item
        Visible = True
        ItemName = 'dxBarButton11'
      end>
    UseOwnFont = False
    Left = 168
    Top = 216
    PixelsPerInch = 96
  end
end
