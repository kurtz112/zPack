object zViewerWordFrame: TzViewerWordFrame
  Left = 0
  Top = 0
  Width = 903
  Height = 460
  TabOrder = 0
  object dxRichEditControl: TdxRichEditControl
    Left = 0
    Top = 26
    Width = 903
    Height = 415
    Align = alClient
    Options.DocumentSaveOptions.DefaultFormat = OpenXml
    Options.Fields.UseCurrentCultureDateTimeFormat = True
    Options.HorizontalRuler.Visibility = Hidden
    Options.VerticalRuler.Visibility = Hidden
    TabOrder = 0
    MeasurementUnit = Centimeter
  end
  object StatusBar: TdxStatusBar
    Left = 0
    Top = 441
    Width = 903
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
      'Page Layout | Page Setup'
      'View | Document Views'
      'View | Show'
      'View | Zoom'
      'File | Print')
    Categories.ItemsVisibles = (
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
      True)
    ImageOptions.Images = dx.Immagini
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 352
    Top = 40
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
      FloatLeft = 853
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      Glyph.SourceDPI = 96
      Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000000B744558745469746C6500536176653BF9E8F9090000020349444154
        785E7D52316B145110FEDEE6EE9A03EF2E57284A6C6DAC42C0262185829D0A36
        16820AFE010BADC47F60AB2022585A588875B01041822158D858081204956872
        DC5DD6DD3733CF99D93DD713CCC0F7BEF776E7FB66E6ED0654912982633EFCFC
        9F67A2603B2CAC9DBFB2810CEB4B274EE1E4D271B0303832A24450A94C113112
        2846ECED8F301A7DB59CD76F379E9F6D9901425A5F3DB38C4F9FC7B87BE70690
        60E1E49C80BC886049B87EF33656964F6373EBFD1A8096190466017352B0ABA6
        BF22C4D5C9C5972E5CD632010F1F3F0553C4CECE17088B8F9ED99292B898884C
        EFE2548B270711D942867E7F114717BB9E0308582A83962D2C6EE0EE2925EFA6
        245671899205ED561B9D4EA77EC7CA6D887063904CCCE29735C923BEEF4F91C4
        A771DC7FF008C7865DEF88896B23FA6310BC03226FEFEAB55B9A203E63823143
        5490445C3883D05F23F8FCC228F26F180C06B3CB730059BD57866F20229EDF18
        D42358BC78F60487C5EAB98B5A6408E63903B1F6BD358B9FE302F06D729610BC
        B2AE20B63CF9D780602072579FB9F98B6082E6DF8D044932FF156CA648EC89F7
        5E7E844802299851B3C26667F30BCAF31D043B3091DFC3917E0F5C895C1C4D3C
        03E095C79303A4CA20984111CBFCDDE6D6F6CA70D0C39B571F2A7164AF129589
        14C65E59B0FB631765596C03C8030033E929BA8A0C4D8443F6A2982AF67E037E
        F6AC9379188DF20000000049454E44AE426082}
      ItemLinks = <
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonImporta'
        end
        item
          Visible = True
          ItemName = 'dxBarButton1'
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
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonSimpleView'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonDraftView'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonPrintLayout'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonZoomOut'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonZoomIn'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object dxBarButtonImporta: TdxBarButton
      Action = Importa
      Category = 0
    end
    object dxBarButton1: TdxBarButton
      Action = Apri
      Category = 0
    end
    object dxBarButtonSaveAs: TdxBarButton
      Action = dxRichEditControlSaveDocumentAs
      Category = 1
      LargeImageIndex = 92
    end
    object dxBarButtonPaste: TdxBarButton
      Action = dxRichEditControlPasteSelection
      Category = 2
      LargeImageIndex = 85
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
    object dxBarButtonCustomMargins: TdxBarButton
      Action = dxRichEditControlShowPageMarginsSetupForm
      Category = 3
      LargeImageIndex = 294
    end
    object dxBarButtonPortrait: TdxBarButton
      Action = dxRichEditControlSetPortraitPageOrientation
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 300
    end
    object dxBarButtonLandscape: TdxBarButton
      Action = dxRichEditControlSetLandscapePageOrientation
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 299
    end
    object dxBarButtonMorePaperSizes: TdxBarButton
      Action = dxRichEditControlShowPagePaperSetupForm
      Category = 3
      LargeImageIndex = 306
    end
    object dxBarButtonOne: TdxBarButton
      Action = dxRichEditControlSetSectionOneColumn
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 267
    end
    object dxBarButtonTwo: TdxBarButton
      Action = dxRichEditControlSetSectionTwoColumns
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 269
    end
    object dxBarButtonThree: TdxBarButton
      Action = dxRichEditControlSetSectionThreeColumns
      Category = 3
      ButtonStyle = bsChecked
      LargeImageIndex = 268
    end
    object dxBarButtonMoreColumns: TdxBarButton
      Action = dxRichEditControlShowColumnsSetupForm
      Category = 3
      LargeImageIndex = 266
    end
    object dxBarButtonPage: TdxBarButton
      Action = dxRichEditControlInsertPageBreak
      Category = 3
      LargeImageIndex = 105
    end
    object dxBarButtonColumn: TdxBarButton
      Action = dxRichEditControlInsertColumnBreak
      Category = 3
      LargeImageIndex = 99
    end
    object dxBarButtonSectionNextPage: TdxBarButton
      Action = dxRichEditControlInsertSectionBreakNextPage
      Category = 3
      LargeImageIndex = 110
    end
    object dxBarButtonSectionEvenPage: TdxBarButton
      Action = dxRichEditControlInsertSectionBreakEvenPage
      Category = 3
      LargeImageIndex = 109
    end
    object dxBarButtonSectionOddPage: TdxBarButton
      Action = dxRichEditControlInsertSectionBreakOddPage
      Category = 3
      LargeImageIndex = 111
    end
    object dxBarButtonNone: TdxBarButton
      Action = dxRichEditControlSetSectionLineNumberingNone
      Category = 3
      ButtonStyle = bsChecked
    end
    object dxBarButtonContinuous: TdxBarButton
      Action = dxRichEditControlSetSectionLineNumberingContinuous
      Category = 3
      ButtonStyle = bsChecked
    end
    object dxBarButtonRestartEachPage: TdxBarButton
      Action = dxRichEditControlSetSectionLineNumberingRestartNewPage
      Category = 3
      ButtonStyle = bsChecked
    end
    object dxBarButtonRestartEachSection: TdxBarButton
      Action = dxRichEditControlSetSectionLineNumberingRestartNewSection
      Category = 3
      ButtonStyle = bsChecked
    end
    object dxBarButtonLineNumberingOptions: TdxBarButton
      Action = dxRichEditControlShowLineNumberingForm
      Category = 3
    end
    object dxBarButtonSimpleView: TdxBarButton
      Action = dxRichEditControlSwitchToSimpleView
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 453
    end
    object dxBarButtonDraftView: TdxBarButton
      Action = dxRichEditControlSwitchToDraftView
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 439
    end
    object dxBarButtonPrintLayout: TdxBarButton
      Action = dxRichEditControlSwitchToPrintLayoutView
      Category = 4
      ButtonStyle = bsChecked
      LargeImageIndex = 210
    end
    object dxBarButtonZoomOut: TdxBarButton
      Action = dxRichEditControlZoomOut
      Category = 6
      LargeImageIndex = 460
    end
    object dxBarButtonZoomIn: TdxBarButton
      Action = dxRichEditControlZoomIn
      Category = 6
      LargeImageIndex = 459
    end
    object dxBarButtonPrint: TdxBarButton
      Action = dxRichEditControlShowPrintForm
      Category = 7
      LargeImageIndex = 208
    end
    object dxBarButtonPrintPreview: TdxBarButton
      Action = dxRichEditControlShowPrintPreviewForm
      Category = 7
      LargeImageIndex = 169
    end
    object dxBarButtonPageSetup: TdxBarButton
      Action = dxRichEditControlShowPageSetupForm
      Category = 7
      LargeImageIndex = 517
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 344
    Top = 112
    object dxRichEditControlNewDocument: TdxRichEditControlNewDocument
      Category = 'DevExpress RichEdit Control.File.Common'
      ImageIndex = 1
    end
    object dxRichEditControlLoadDocument: TdxRichEditControlLoadDocument
      Category = 'DevExpress RichEdit Control.File.Common'
      ImageIndex = 36
    end
    object dxRichEditControlSaveDocument: TdxRichEditControlSaveDocument
      Category = 'DevExpress RichEdit Control.File.Common'
      ImageIndex = 92
    end
    object dxRichEditControlSaveDocumentAs: TdxRichEditControlSaveDocumentAs
      Category = 'DevExpress RichEdit Control.File.Common'
      ImageIndex = 92
    end
    object dxRichEditControlPasteSelection: TdxRichEditControlPasteSelection
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      ImageIndex = 85
    end
    object dxRichEditControlCutSelection: TdxRichEditControlCutSelection
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      ImageIndex = 65
    end
    object dxRichEditControlCopySelection: TdxRichEditControlCopySelection
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      ImageIndex = 62
    end
    object dxRichEditControlSelectAll: TdxRichEditControlSelectAll
      Category = 'DevExpress RichEdit Control.Home.Clipboard'
      ImageIndex = 193
    end
    object dxRichEditControlPageMarginsGallery: TdxRichEditControlPageMarginsGallery
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 294
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
      ImageIndex = 306
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
    object dxRichEditControlInsertPageBreak: TdxRichEditControlInsertPageBreak
      Category = 'DevExpress RichEdit Control.Page Layout.Page Setup'
      ImageIndex = 105
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
    object dxRichEditControlSwitchToSimpleView: TdxRichEditControlSwitchToSimpleView
      Category = 'DevExpress RichEdit Control.View.Document Views'
      ImageIndex = 453
    end
    object dxRichEditControlSwitchToDraftView: TdxRichEditControlSwitchToDraftView
      Category = 'DevExpress RichEdit Control.View.Document Views'
      ImageIndex = 439
    end
    object dxRichEditControlSwitchToPrintLayoutView: TdxRichEditControlSwitchToPrintLayoutView
      Category = 'DevExpress RichEdit Control.View.Document Views'
      ImageIndex = 210
    end
    object dxRichEditControlToggleShowHorizontalRuler: TdxRichEditControlToggleShowHorizontalRuler
      Category = 'DevExpress RichEdit Control.View.Show'
      ImageIndex = 445
    end
    object dxRichEditControlToggleShowVerticalRuler: TdxRichEditControlToggleShowVerticalRuler
      Category = 'DevExpress RichEdit Control.View.Show'
      ImageIndex = 446
    end
    object dxRichEditControlZoomOut: TdxRichEditControlZoomOut
      Category = 'DevExpress RichEdit Control.View.Zoom'
      ImageIndex = 460
    end
    object dxRichEditControlZoomIn: TdxRichEditControlZoomIn
      Category = 'DevExpress RichEdit Control.View.Zoom'
      ImageIndex = 459
    end
    object dxRichEditControlShowPrintForm: TdxRichEditControlShowPrintForm
      Category = 'DevExpress RichEdit Control.File.Print'
      ImageIndex = 208
    end
    object dxRichEditControlShowPrintPreviewForm: TdxRichEditControlShowPrintPreviewForm
      Category = 'DevExpress RichEdit Control.File.Print'
      ImageIndex = 169
    end
    object dxRichEditControlShowPageSetupForm: TdxRichEditControlShowPageSetupForm
      Category = 'DevExpress RichEdit Control.File.Print'
      ImageIndex = 517
    end
    object Importa: TdxFileOpen
      Caption = 'Importa'
      Dialog.DefaultExt = '*.docx'
      Dialog.Filter = 'Word|*.docx|Word 97 |*.doc|Tutti|*.*'
      Hint = 'apri un file esistente'
      ImageIndex = 238
      OnAccept = ImportaAccept
      OnUpdate = ImportaUpdate
    end
    object Apri: TAction
      Caption = 'Apri'
      ImageIndex = 36
      OnExecute = ApriExecute
    end
  end
  object dxRibbonGalleryItem1: TdxRibbonGalleryItem
    Caption = 'Margins'
    Category = -1
    Visible = ivAlways
    GalleryOptions.ColumnCount = 1
    GalleryFilter.Categories = <>
    GalleryInRibbonOptions.Collapsed = True
    GalleryInRibbonOptions.MinColumnCount = 1
    GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
    GalleryInMenuOptions.ItemTextKind = itkCaptionAndDescription
    ItemLinks = <>
  end
  object dxRibbonGalleryItem2: TdxRibbonGalleryItem
    Caption = 'Size'
    Category = -1
    Visible = ivAlways
    GalleryOptions.ColumnCount = 1
    GalleryOptions.LongDescriptionDefaultRowCount = 1
    GalleryFilter.Categories = <>
    GalleryInRibbonOptions.Collapsed = True
    GalleryInRibbonOptions.MinColumnCount = 1
    GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
    GalleryInMenuOptions.ItemTextKind = itkCaptionAndDescription
    ItemLinks = <>
  end
end
