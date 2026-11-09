object zImageForm: TzImageForm
  Left = 0
  Top = 0
  ClientHeight = 371
  ClientWidth = 423
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  
  TextHeight = 13
  object OkCancel: TOkCancel
    Left = 0
    Top = 341
    Width = 423
    Height = 30
    Align = alBottom
    TabOrder = 0
     
    DefaultOk = False
    DefaultCancel = False
  end
  object cxImage: TcxImage
    AlignWithMargins = True
    Left = 3
    Top = 31
    Align = alClient
    PopupMenu = dxBarPopupMenu
    Properties.GraphicClassName = 'TdxSmartImage'
    TabOrder = 1
    ExplicitTop = 29
    ExplicitHeight = 309
    Height = 307
    Width = 417
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 168
    Top = 48
    object FileOpen: TAction
      Caption = 'Apri'
      ImageIndex = 36
      ShortCut = 16463
      OnExecute = FileOpenExecute
    end
    object FileSaveAs: TAction
      Caption = 'Salva'
      ImageIndex = 92
      OnExecute = FileSaveAsExecute
    end
    object EditCut: TAction
      Caption = 'Taglia'
      ImageIndex = 65
      ShortCut = 16472
      OnExecute = EditCutExecute
    end
    object EditCopy: TAction
      Caption = 'Copia'
      ImageIndex = 62
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
    
    DockControlHeights = (
      0
      0
      28
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
    object dxBarButton11: TdxBarButton
      Caption = 'Seleziona Tutto'
      Category = 0
      Visible = ivAlways
      ImageIndex = 193
      ShortCut = 16449
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
    
  end
end
