object zMemoForm: TzMemoForm
  Left = 0
  Top = 0
  ClientHeight = 336
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 13
  object OkCancel: TOkCancel
    Left = 0
    Top = 306
    Width = 635
    Height = 30
    Align = alBottom
    TabOrder = 0
    DefaultOk = False
    DefaultCancel = False
  end
  object cxMemo: TcxMemo
    AlignWithMargins = True
    Left = 3
    Top = 29
    Align = alClient
    PopupMenu = dxBarPopupMenu
    Properties.ScrollBars = ssBoth
    TabOrder = 1
    ExplicitLeft = -2
    ExplicitTop = 26
    Height = 274
    Width = 629
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 168
    Top = 48
    object FileOpen: TdxFileOpen
      Caption = 'Apri'
      Dialog.DefaultExt = '*.txt'
      Dialog.Filter = 'Testo|*.txt|Tutti|*.*'
      ImageIndex = 36
      ShortCut = 16463
      OnAccept = FileOpenAccept
    end
    object FileSaveAs: TdxFileSaveAs
      Caption = 'Salva su file...'
      Dialog.DefaultExt = '*.txt'
      Dialog.Filter = 'Testo|*.txt|Tutti|*.*'
      ImageIndex = 92
      OnAccept = FileSaveAsAccept
    end
    object EditUndo: TEditUndo
      Caption = 'Annulla'
      ImageIndex = 96
      ShortCut = 16474
    end
    object EditCut: TEditCut
      Caption = 'Taglia'
      ImageIndex = 65
      ShortCut = 16472
    end
    object EditCopy: TEditCopy
      Caption = 'Copia'
      ImageIndex = 62
      ShortCut = 16451
    end
    object EditPaste: TEditPaste
      Caption = 'Incolla'
      ImageIndex = 85
      ShortCut = 16470
    end
    object EditDelete: TEditDelete
      Caption = 'Elimina'
      ImageIndex = 66
      ShortCut = 46
    end
    object EditSelectAll: TEditSelectAll
      Caption = 'Seleziona Tutto'
      ImageIndex = 193
      ShortCut = 16449
    end
    object Trova: TAction
      Caption = '&Trova...'
      ImageIndex = 189
      ShortCut = 16454
      OnExecute = TrovaExecute
    end
    object Sostituisci: TAction
      Caption = 'Sostituisci'
      ImageIndex = 192
      ShortCut = 16456
      OnExecute = SostituisciExecute
      OnUpdate = SostituisciUpdate
    end
    object Successivo: TAction
      Caption = 'Successivo'
      ImageIndex = 189
      ShortCut = 114
      OnExecute = SuccessivoExecute
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
          Visible = True
          ItemName = 'dxBarStatic1'
        end
        item
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
          Visible = True
          ItemName = 'dxBarButton8'
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
          ItemName = 'dxBarButton4'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
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
          ItemName = 'dxBarButton13'
        end>
      NotDocking = [dsNone, dsLeft, dsRight, dsBottom]
      OneOnRow = False
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBarFree: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 407
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 669
      FloatTop = 8
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarStatic2'
        end>
      OneOnRow = False
      Row = 0
      ShowMark = False
      SizeGrip = False
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
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
      Action = Trova
      Category = 0
    end
    object dxBarButton10: TdxBarButton
      Action = Sostituisci
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Action = Successivo
      Category = 0
    end
    object dxBarButton13: TdxBarButton
      Action = Trova
      Category = 0
    end
    object dxBarStatic1: TdxBarStatic
      Caption = ' '
      Category = 0
      Hint = ' '
      Visible = ivAlways
    end
    object dxBarStatic2: TdxBarStatic
      Caption = ' '
      Category = 0
      Hint = ' '
      Visible = ivAlways
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
      end>
    UseOwnFont = False
    Left = 168
    Top = 216
    PixelsPerInch = 96
  end
end
