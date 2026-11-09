object zViewerImageForm: TzViewerImageForm
  Left = 0
  Top = 0
  Caption = 'zViewerImageForm'
  ClientHeight = 440
  ClientWidth = 938
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object cxImage: TcxImage
    Left = 0
    Top = 158
    Align = alClient
    Properties.FitMode = ifmProportionalStretch
    Properties.GraphicClassName = 'TdxSmartImage'
    ZoomingOptions.ShowZoomTrackBar = True
    TabOrder = 0
    Height = 259
    Width = 938
  end
  object dxRibbonStatusBar: TdxRibbonStatusBar
    Left = 0
    Top = 417
    Width = 938
    Height = 23
    Color = clBtnFace
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Fixed = False
      end
      item
        PanelStyleClassName = 'TdxStatusBarToolbarPanelStyle'
        PanelStyle.ToolbarName = 'biStatusBarZoom'
        MinWidth = 39
        Text = 'TdxStatusBarPanel'
        Width = 39
      end
      item
        PanelStyleClassName = 'TdxStatusBarContainerPanelStyle'
        PanelStyle.Container = dxRibbonStatusBarContainer1
        MinWidth = 150
        Width = 150
      end>
    Ribbon = dxRibbon
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    object dxRibbonStatusBarContainer1: TdxStatusBarContainerControl
      Left = 767
      Top = 0
      Width = 152
      Height = 23
      object tbZoom: TdxZoomTrackBar
        Left = 0
        Top = 0
        Align = alClient
        Properties.FirstRange.Frequency = 5
        Properties.OnChange = tbZoomPropertiesChange
        TabOrder = 0
        Height = 23
        Width = 152
      end
    end
  end
  object dxRibbon: TdxRibbon
    Left = 0
    Top = 0
    Width = 938
    Height = 132
    BarManager = dxBarManager
    Style = rs2019
    ColorSchemeAccent = rcsaGreen
    ColorSchemeName = 'White'
    PopupMenuItems = [rpmiQATPosition, rpmiQATAddRemoveItem, rpmiMinimizeRibbon]
    SupportNonClientDrawing = True
    Contexts = <>
    TabOrder = 2
    TabStop = False
    object dxRibbonTabFile: TdxRibbonTab
      Active = True
      Caption = 'File'
      Groups = <
        item
          ToolbarName = 'dxBarManagerBarFile'
        end
        item
          ToolbarName = 'dxBarManagerBarEdita'
        end
        item
          ToolbarName = 'dxBarManagerBarImage'
        end
        item
          ToolbarName = 'dxBarManagerBarChiudi'
        end>
      Index = 0
    end
  end
  object Printer: TdxComponentPrinter
    CurrentLink = PrinterLink
    PreviewOptions.SaveZoomPosition = False
    PreviewOptions.Caption = 'Anteprima'
    PreviewOptions.WindowState = wsMaximized
    PreviewOptions.PreviewBoundsRect = {0000000000000000E803000020030000}
    Version = 0
    Left = 408
    Top = 333
    PixelsPerInch = 96
    object PrinterLink: TcxImageReportLink
      Component = cxImage
      PrinterPage.DMPaper = 9
      PrinterPage.Footer = 6350
      PrinterPage.GrayShading = True
      PrinterPage.Header = 6350
      PrinterPage.Margins.Bottom = 12700
      PrinterPage.Margins.Left = 12700
      PrinterPage.Margins.Right = 12700
      PrinterPage.Margins.Top = 12700
      PrinterPage.PageSize.X = 210000
      PrinterPage.PageSize.Y = 297000
      PrinterPage._dxMeasurementUnits_ = 0
      PrinterPage._dxLastMU_ = 2
      ReportDocument.Caption = 'Immagine'
      PixelsPerInch = 96
      BuiltInReportLink = True
    end
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 408
    Top = 112
    object SalvaConNome: TAction
      Caption = 'Salva con nome'
      ImageIndex = 92
      OnExecute = SalvaConNomeExecute
    end
    object Anteprima: TAction
      Caption = 'Anteprima'
      ImageIndex = 169
      OnExecute = AnteprimaExecute
    end
    object Chiudi: TAction
      Caption = 'Chiudi'
      ImageIndex = 60
      OnExecute = ChiudiExecute
    end
    object Taglia: TAction
      Caption = 'Taglia'
      ImageIndex = 65
      OnExecute = TagliaExecute
    end
    object Copia: TAction
      Caption = 'Copia'
      ImageIndex = 62
      OnExecute = CopiaExecute
    end
    object Incolla: TAction
      Caption = 'Incolla'
      ImageIndex = 85
      OnExecute = IncollaExecute
    end
    object Elimina: TAction
      Caption = 'Elimina'
      ImageIndex = 66
      OnExecute = EliminaExecute
    end
    object Centra: TAction
      AutoCheck = True
      Caption = 'Centra'
      ImageIndex = 421
      OnExecute = CentraExecute
    end
    object Trasparente: TAction
      AutoCheck = True
      Caption = 'Trasparente'
      ImageIndex = 424
      OnExecute = TrasparenteExecute
    end
    object Proporzionale: TAction
      AutoCheck = True
      Caption = 'Proporzionale'
      ImageIndex = 422
      OnExecute = ProporzionaleExecute
    end
    object Stretch: TAction
      AutoCheck = True
      Caption = 'Stretch'
      ImageIndex = 198
      OnExecute = StretchExecute
    end
    object actShellExecute: TAction
      Caption = 'Editor sistema'
      ImageIndex = 37
      OnExecute = actShellExecuteExecute
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
    Left = 408
    Top = 48
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      26
      0)
    object dxBarManagerBarZoom: TdxBar
      Caption = 'Zoom'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 648
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object biStatusBarZoom: TdxBar
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'StatusBarZoom'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 1105
      FloatTop = 8
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'biStatusBarCurrentZoom'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBarFile: TdxBar
      Caption = 'File'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 648
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton9'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton4'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton6'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBarImage: TdxBar
      Caption = 'Immagine'
      CaptionButtons = <>
      DockedLeft = 402
      DockedTop = 0
      FloatLeft = 648
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton3'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton7'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton8'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBarChiudi: TdxBar
      Caption = 'Chiudi'
      CaptionButtons = <>
      DockedLeft = 693
      DockedTop = 0
      FloatLeft = 648
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton1'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBarEdita: TdxBar
      Caption = 'Edita'
      CaptionButtons = <>
      DockedLeft = 216
      DockedTop = 0
      FloatLeft = 648
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarSubItem14'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton5'
        end
        item
          Visible = True
          ItemName = 'dxBarButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarButton2'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object biStatusBarCurrentZoom: TdxBarStatic
      Caption = '100%'
      Category = 0
      Hint = '100%'
      Visible = ivAlways
    end
    object dxBarLargeButton1: TdxBarLargeButton
      Action = Chiudi
      Category = 0
    end
    object dxBarLargeButton2: TdxBarLargeButton
      Action = Centra
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarLargeButton3: TdxBarLargeButton
      Action = Trasparente
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarLargeButton5: TdxBarLargeButton
      Action = Incolla
      Category = 0
    end
    object dxBarSubItem14: TdxBarSubItem
      Action = Copia
      Category = 0
      ItemLinks = <>
    end
    object dxBarButton1: TdxBarButton
      Action = Taglia
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = Elimina
      Category = 0
    end
    object dxBarLargeButton4: TdxBarLargeButton
      Action = SalvaConNome
      Category = 0
    end
    object dxBarLargeButton6: TdxBarLargeButton
      Action = Anteprima
      Category = 0
    end
    object dxBarLargeButton7: TdxBarLargeButton
      Action = Proporzionale
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarLargeButton8: TdxBarLargeButton
      Action = Stretch
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarLargeButton9: TdxBarLargeButton
      Action = actShellExecute
      Category = 0
    end
    object cxBarEditItemFont: TcxBarEditItem
      Caption = 'Font'
      Category = 3
      Hint = 'Change the font face.'
      Visible = ivAlways
      ImageIndex = 329
      PropertiesClassName = 'TcxFontNameComboBoxProperties'
      Properties.FontPreview.Visible = False
      Properties.FontTypes = [cxftTTF]
    end
    object cxBarEditItemFontSize: TcxBarEditItem
      Caption = 'Font Size'
      Category = 3
      Hint = 'Change the font size.'
      Visible = ivAlways
      ImageIndex = 331
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
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'Change Case'
      Category = 3
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxRibbonColorGalleryItemTextHighlightColor: TdxRibbonColorGalleryItem
      Caption = 'Text Highlight Color'
      Category = 3
      Hint = 'Make text look like it was marked with a highlighter pen.'
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
    end
    object dxRibbonColorGalleryItemFontColor: TdxRibbonColorGalleryItem
      Caption = 'Font Color'
      Category = 3
      Hint = 'Change the font color.'
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
    end
    object dxBarSubItem2: TdxBarSubItem
      Caption = 'Line Spacing'
      Category = 4
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxRibbonGalleryItemQuickStyles: TdxRibbonGalleryItem
      Caption = 'Quick Styles'
      Category = 5
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      GalleryOptions.ColumnCount = 4
      GalleryFilter.Categories = <>
      GalleryInMenuOptions.CollapsedInSubmenu = False
      GalleryInMenuOptions.DropDownGalleryResizing = gsrHeight
      GalleryInMenuOptions.ItemTextKind = itkNone
      ItemLinks = <>
      object dxRibbonGalleryItemQuickStylesGroup1: TdxRibbonGalleryGroup
      end
    end
    object dxRibbonGalleryItemMargins: TdxRibbonGalleryItem
      Caption = 'Margini'
      Category = 14
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      GalleryOptions.ColumnCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkCaptionAndDescription
      ItemLinks = <>
      object dxRibbonGalleryItemMarginsGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemMarginsGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Normal'
          Description = 'Top:'#9'0,79 in    Bottom:'#9'0,79 in'#13#10'Left:'#9'1,18 in    Right:'#9'0,59 in'
          ImageIndex = -1
          ActionIndex = 0
        end
        object dxRibbonGalleryItemMarginsGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Narrow'
          Description = 'Top:'#9'0,50 in    Bottom:'#9'0,50 in'#13#10'Left:'#9'0,50 in    Right:'#9'0,50 in'
          ImageIndex = -1
          ActionIndex = 1
        end
        object dxRibbonGalleryItemMarginsGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Moderate'
          Description = 'Top:'#9'1,00 in    Bottom:'#9'1,00 in'#13#10'Left:'#9'0,75 in    Right:'#9'0,75 in'
          ImageIndex = -1
          ActionIndex = 2
        end
        object dxRibbonGalleryItemMarginsGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'Wide'
          Description = 'Top:'#9'1,00 in    Bottom:'#9'1,00 in'#13#10'Left:'#9'2,00 in    Right:'#9'2,00 in'
          ImageIndex = -1
          ActionIndex = 3
        end
      end
    end
    object dxBarSubItem3: TdxBarSubItem
      Caption = 'Orientamento'
      Category = 14
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxRibbonGalleryItemSize: TdxRibbonGalleryItem
      Caption = 'Dimensioni'
      Category = 14
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      GalleryOptions.ColumnCount = 1
      GalleryOptions.LongDescriptionDefaultRowCount = 1
      GalleryFilter.Categories = <>
      GalleryInRibbonOptions.Collapsed = True
      GalleryInRibbonOptions.MinColumnCount = 1
      GalleryInMenuOptions.DropDownGalleryResizing = gsrNone
      GalleryInMenuOptions.ItemTextKind = itkCaptionAndDescription
      ItemLinks = <>
      object dxRibbonGalleryItemSizeGroup1: TdxRibbonGalleryGroup
        Options.Images = dx.Immagini
        Options.ItemImageSize.Height = 32
        Options.ItemImageSize.Width = 32
        object dxRibbonGalleryItemSizeGroup1Item1: TdxRibbonGalleryGroupItem
          Caption = 'Letter'
          Description = '216,00 mm x 279,00 mm'
          ImageIndex = -1
          ActionIndex = 1
        end
        object dxRibbonGalleryItemSizeGroup1Item2: TdxRibbonGalleryGroupItem
          Caption = 'Tabloid'
          Description = '279,00 mm x 432,00 mm'
          ImageIndex = -1
          ActionIndex = 3
        end
        object dxRibbonGalleryItemSizeGroup1Item3: TdxRibbonGalleryGroupItem
          Caption = 'Legal'
          Description = '216,00 mm x 356,00 mm'
          ImageIndex = -1
          ActionIndex = 5
        end
        object dxRibbonGalleryItemSizeGroup1Item4: TdxRibbonGalleryGroupItem
          Caption = 'Statement'
          Description = '140,00 mm x 216,00 mm'
          ImageIndex = -1
          ActionIndex = 6
        end
        object dxRibbonGalleryItemSizeGroup1Item5: TdxRibbonGalleryGroupItem
          Caption = 'Executive'
          Description = '184,00 mm x 267,00 mm'
          ImageIndex = -1
          ActionIndex = 7
        end
        object dxRibbonGalleryItemSizeGroup1Item6: TdxRibbonGalleryGroupItem
          Caption = 'A3'
          Description = '297,00 mm x 420,00 mm'
          ImageIndex = -1
          ActionIndex = 8
        end
        object dxRibbonGalleryItemSizeGroup1Item7: TdxRibbonGalleryGroupItem
          Caption = 'A4'
          Description = '210,00 mm x 297,00 mm'
          ImageIndex = -1
          ActionIndex = 9
        end
        object dxRibbonGalleryItemSizeGroup1Item8: TdxRibbonGalleryGroupItem
          Caption = 'A5'
          Description = '148,00 mm x 210,00 mm'
          ImageIndex = -1
          ActionIndex = 11
        end
        object dxRibbonGalleryItemSizeGroup1Item9: TdxRibbonGalleryGroupItem
          Caption = 'B4'
          Description = '250,00 mm x 354,00 mm'
          ImageIndex = -1
          ActionIndex = 12
        end
        object dxRibbonGalleryItemSizeGroup1Item10: TdxRibbonGalleryGroupItem
          Caption = 'B5'
          Description = '182,00 mm x 257,00 mm'
          ImageIndex = -1
          ActionIndex = 13
        end
      end
    end
    object dxBarSubItem4: TdxBarSubItem
      Caption = 'Colonne'
      Category = 14
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxBarSubItem5: TdxBarSubItem
      Caption = 'Interruzioni'
      Category = 14
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxBarSubItem6: TdxBarSubItem
      Caption = 'Numeri di riga'
      Category = 14
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxRibbonColorGalleryItemPageColor: TdxRibbonColorGalleryItem
      Caption = 'Colore pagina'
      Category = 15
      Hint = 'Choose a color for the background of the page.'
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
    end
    object dxBarSubItem7: TdxBarSubItem
      Caption = 'Elimina'
      Category = 28
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxBarSubItem8: TdxBarSubItem
      Caption = 'Adatta'
      Category = 30
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxRibbonGalleryItemTableStyles: TdxRibbonGalleryItem
      Caption = 'Table Styles'
      Category = 32
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
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
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxRibbonColorGalleryItemShapeFill: TdxRibbonColorGalleryItem
      Caption = 'Riempimento forma'
      Category = 33
      Hint = 'Fill the selected shape with a solid color.'
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
    end
    object dxRibbonColorGalleryItemShapeOutline: TdxRibbonColorGalleryItem
      Caption = 'Contorno forma'
      Category = 33
      Hint = 'Specify color for the outline of the selected shape.'
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
    end
    object dxBarSubItem10: TdxBarSubItem
      Caption = 'Testo a capo'
      Category = 34
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxBarSubItem11: TdxBarSubItem
      Caption = 'Posizione'
      Category = 34
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxBarSubItem12: TdxBarSubItem
      Caption = 'Porta avandi'
      Category = 34
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
    object dxBarSubItem13: TdxBarSubItem
      Caption = 'Porta indietro'
      Category = 34
      Visible = ivAlways
      ImageIndex = -1
      LargeImageIndex = -1
      ItemLinks = <>
    end
  end
end
