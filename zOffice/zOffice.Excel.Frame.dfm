object zViewerExcelFrame: TzViewerExcelFrame
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  object StatusBar: TdxStatusBar
    Left = 0
    Top = 461
    Width = 640
    Height = 19
    Panels = <
      item
        Fixed = False
        Width = 50
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
      end>
    SizeGrip = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object dxSpreadSheet: TdxSpreadSheet
    Left = 0
    Top = 26
    Width = 640
    Height = 435
    Align = alClient
    ExplicitTop = 28
    ExplicitHeight = 433
    Data = {
      9002000044585353763242461000000042465320000000000000000001000101
      010100000100000001004246532000000000424653200100000001000000200B
      00000007000000430061006C0069006200720069000000000000002000000020
      0000000020000000000020000000000020000000000020000007000000470045
      004E004500520041004C00000000000002000000000000000001424653200100
      0000424653201700000054006400780053007000720065006100640053006800
      6500650074005400610062006C00650056006900650077000600000053006800
      650065007400310001FFFFFFFFFFFFFFFF640000000200000002000000020000
      0055000000140000000200000002000000000200000002000000000000010000
      0000000101000042465320550000000000000042465320000000004246532014
      0000000000000042465320000000000000000000000000010000000000000000
      0000000000000000000000424653200000000002020000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000064000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000200020200020000000000000000000000000000000000020000000000
      0000000000000000000000000000000000000000000000000000000000000202
      0000000000000000424653200000000000000000040000004C00750063006100
      0000000000000000040000004C0075006300610000000000000000002B13A5BF
      AFE7E54002E4ACBFAFE7E5400000000000000000}
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
      'View | Zoom')
    Categories.ItemsVisibles = (
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
      True)
    ImageOptions.Images = dx.Immagini
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 272
    Top = 72
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      26
      0)
    object dxBarManagerBar: TdxBar
      Caption = 'Common'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 650
      FloatTop = 0
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
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonSaveAs'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonPrint'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonPrintPreview'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonPageSetup'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonPaste'
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
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonZoomOut'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonZoomIn'
        end
        item
          Visible = True
          ItemName = 'dxBarButton100'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object dxBarButton1: TdxBarButton
      Action = Importa
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = Apri
      Category = 0
    end
    object dxBarButtonSaveAs: TdxBarButton
      Action = dxSpreadSheetSaveDocumentAs
      Category = 1
      LargeImageIndex = 92
    end
    object dxBarButtonPrint: TdxBarButton
      Action = dxSpreadSheetShowPrintForm
      Category = 2
      LargeImageIndex = 208
    end
    object dxBarButtonPrintPreview: TdxBarButton
      Action = dxSpreadSheetShowPrintPreviewForm
      Category = 2
      LargeImageIndex = 169
    end
    object dxBarButtonPageSetup: TdxBarButton
      Action = dxSpreadSheetShowPageSetupForm
      Category = 2
      LargeImageIndex = 517
    end
    object dxBarButtonPaste: TdxBarButton
      Action = dxSpreadSheetPasteSelection
      Category = 3
      LargeImageIndex = 85
    end
    object dxBarButtonCut: TdxBarButton
      Action = dxSpreadSheetCutSelection
      Category = 3
      LargeImageIndex = 65
    end
    object dxBarButtonCopy: TdxBarButton
      Action = dxSpreadSheetCopySelection
      Category = 3
      LargeImageIndex = 62
    end
    object dxBarButtonZoomOut: TdxBarButton
      Action = dxSpreadSheetZoomOut
      Category = 4
      LargeImageIndex = 460
    end
    object dxBarButtonZoomIn: TdxBarButton
      Action = dxSpreadSheetZoomIn
      Category = 4
      LargeImageIndex = 459
    end
    object dxBarButton100: TdxBarButton
      Action = dxSpreadSheetZoomDefault
      Category = 4
      LargeImageIndex = 458
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 272
    Top = 136
    object dxSpreadSheetNewDocument: TdxSpreadSheetNewDocument
      Category = 'DevExpress ExpressSpreadSheet.File.Common'
      ImageIndex = 1
    end
    object dxSpreadSheetOpenDocument: TdxSpreadSheetOpenDocument
      Category = 'DevExpress ExpressSpreadSheet.File.Common'
      ImageIndex = 36
    end
    object dxSpreadSheetSaveDocumentAs: TdxSpreadSheetSaveDocumentAs
      Category = 'DevExpress ExpressSpreadSheet.File.Common'
      ImageIndex = 92
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
      ImageIndex = 517
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
      ImageIndex = 62
    end
    object dxSpreadSheetZoomOut: TdxSpreadSheetZoomOut
      Category = 'DevExpress ExpressSpreadSheet.View.Zoom'
      ImageIndex = 460
    end
    object dxSpreadSheetZoomIn: TdxSpreadSheetZoomIn
      Category = 'DevExpress ExpressSpreadSheet.View.Zoom'
      ImageIndex = 459
    end
    object dxSpreadSheetZoomDefault: TdxSpreadSheetZoomDefault
      Category = 'DevExpress ExpressSpreadSheet.View.Zoom'
      ImageIndex = 458
    end
    object Importa: TdxFileOpen
      Caption = 'Importa'
      Dialog.DefaultExt = '*.xlsx'
      Dialog.Filter = 'Excel|*.xlsx|Excel 97 |*.xls|CSV|*.csv|Tutti|*.*'
      Hint = 'apri un file esistente'
      ImageIndex = 238
      OnAccept = ImportaAccept
      OnUpdate = ImportaUpdate
    end
    object Apri: TAction
      Caption = 'Apri '
      ImageIndex = 36
      OnExecute = ApriExecute
    end
  end
end
