object zOfficeFastReportForm: TzOfficeFastReportForm
  Left = 0
  Top = 0
  Caption = 'Anteprima Report'
  ClientHeight = 600
  ClientWidth = 1199
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  WindowState = wsMaximized
  OnMouseWheel = FormMouseWheel
  TextHeight = 13
  object frxPreview: TfrxPreview
    Left = 0
    Top = 129
    Width = 1199
    Height = 448
    Align = alClient
    OutlineVisible = True
    OutlineWidth = 120
    ThumbnailVisible = False
    FindFmVisible = False
    OnPageChanged = frxPreviewPageChanged
    UseReportHints = True
    OutlineTreeSortType = dtsUnsorted
    HideScrolls = False
  end
  object dxRibbon: TdxRibbon
    Left = 0
    Top = 0
    Width = 1199
    Height = 129
    BarManager = dxBarManager
    Style = rsOffice365
    ColorSchemeName = 'MoneyTwins'
    Contexts = <>
    TabOrder = 1
    TabStop = False
    object dxRibbonTab: TdxRibbonTab
      Active = True
      Caption = 'Anteprima'
      Groups = <
        item
          ToolbarName = 'dxBarManagerBar1'
        end
        item
          ToolbarName = 'barDocumento'
        end
        item
          ToolbarName = 'dxBarManagerBar2'
        end
        item
          ToolbarName = 'dxBarManagerBar3'
        end
        item
          ToolbarName = 'dxBarManagerBar4'
        end>
      Index = 0
    end
  end
  object dxRibbonStatusBar: TdxRibbonStatusBar
    Left = 0
    Top = 577
    Width = 1199
    Height = 23
    Color = clBtnFace
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Width = 150
      end
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        Width = 100
      end>
    Ribbon = dxRibbon
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 304
    Top = 192
    object actPrint: TAction
      Caption = 'Stampa'
      ImageIndex = 208
      OnExecute = actPrintExecute
    end
    object actOpen: TAction
      Caption = 'Apri'
      ImageIndex = 36
      OnExecute = actOpenExecute
    end
    object actSave: TAction
      Caption = 'Salva'
      ImageIndex = 92
      OnExecute = actSaveExecute
    end
    object actPdf: TAction
      Caption = 'Esporta PDF'
      ImageIndex = 363
      OnExecute = actPdfExecute
    end
    object actEmail: TAction
      Caption = 'Invia Email'
      ImageIndex = 461
      OnExecute = actEmailExecute
    end
    object actFind: TAction
      Caption = 'Trova'
      ImageIndex = 189
      OnExecute = actFindExecute
    end
    object actZoomPlus: TAction
      Caption = 'Zoom In'
      ImageIndex = 459
      OnExecute = actZoomPlusExecute
    end
    object actZoomMinus: TAction
      Caption = 'Zoom Out'
      ImageIndex = 460
      OnExecute = actZoomMinusExecute
    end
    object actFirst: TAction
      Caption = 'Prima Pagina'
      ImageIndex = 146
      OnExecute = actFirstExecute
    end
    object actPrior: TAction
      Caption = 'Pagina Precedente'
      ImageIndex = 168
      OnExecute = actPriorExecute
    end
    object actNext: TAction
      Caption = 'Pagina Successiva'
      ImageIndex = 123
      OnExecute = actNextExecute
    end
    object actLast: TAction
      Caption = 'Ultima Pagina'
      ImageIndex = 156
      OnExecute = actLastExecute
    end
    object actPageSettings: TAction
      Caption = 'Impostazioni Pagina'
      ImageIndex = 289
      OnExecute = actPageSettingsExecute
    end
    object actDesigner: TAction
      Caption = 'Modifica'
      ImageIndex = 44
      OnExecute = actDesignerExecute
    end
    object actCancel: TAction
      Caption = 'Chiudi'
      ImageIndex = 60
      OnExecute = actCancelExecute
    end
    object actZoomWholePage: TAction
      Caption = 'Pagina Intera'
      ImageIndex = 440
      OnExecute = actZoomWholePageExecute
    end
    object actZoomPageWidth: TAction
      Caption = 'Larghezza Pagina'
      ImageIndex = 441
      OnExecute = actZoomPageWidthExecute
    end
    object actZoom100: TAction
      Caption = 'Zoom 100%'
      ImageIndex = 458
      OnExecute = actZoom100Execute
    end
    object Chiudi: TAction
      Caption = 'Chiudi'
      ImageIndex = 60
      OnExecute = ChiudiExecute
    end
    object actDocGeneraAllegato: TAction
      Caption = 'Genera Allegato'
      ImageIndex = 540
      OnExecute = actDocGeneraAllegatoExecute
      OnUpdate = actDocGeneraAllegatoUpdate
    end
    object actDocFirma: TAction
      Caption = 'Firma'
      ImageIndex = 531
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocProtocolla: TAction
      Caption = 'Protocolla'
      ImageIndex = 12
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocConserva: TAction
      Caption = 'Conserva'
      ImageIndex = 10
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocInviaPec: TAction
      Caption = 'Invia PEC'
      ImageIndex = 467
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocInviaMail: TAction
      Caption = 'Invia Mail'
      ImageIndex = 461
      OnExecute = AzioneDocumentoExecute
      OnUpdate = AzioneDocumentoUpdate
    end
    object actDocAggiornaStato: TAction
      Caption = 'Aggiorna stato'
      ImageIndex = 89
      OnExecute = AggiornaStatoDocumentoExecute
      OnUpdate = AggiornaStatoDocumentoUpdate
    end
    object actDocVersioni: TAction
      Caption = 'Versioni'
      ImageIndex = 14
      OnExecute = VersioniDocumentoExecute
      OnUpdate = VersioniDocumentoUpdate
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
    Left = 304
    Top = 128
    PixelsPerInch = 96
    object dxBarManagerBar1: TdxBar
      Caption = 'Azioni'
      CaptionButtons = <>
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 828
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton1'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton8'
        end
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
          ItemName = 'dxBarButton9'
        end
        item
          Visible = True
          ItemName = 'dxBarButton3'
        end
        item
          Visible = True
          ItemName = 'dxBarButton4'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBar2: TdxBar
      Caption = 'Navigazione'
      CaptionButtons = <>
      DockedLeft = 673
      DockedTop = 0
      FloatLeft = 828
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton10'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton11'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton12'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton13'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBar3: TdxBar
      Caption = 'Zoom'
      CaptionButtons = <>
      DockedLeft = 858
      DockedTop = 0
      FloatLeft = 828
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton14'
        end
        item
          Visible = True
          ItemName = 'dxBarLargeButton15'
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
          ItemName = 'dxBarButton7'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarManagerBar4: TdxBar
      Caption = 'Chiudi'
      CaptionButtons = <>
      DockedLeft = 1080
      DockedTop = 0
      FloatLeft = 1064
      FloatTop = 2
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton16'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object barDocumento: TdxBar
      Caption = 'Documento'
      CaptionButtons = <>
      DockedLeft = 277
      DockedTop = 0
      FloatLeft = 909
      FloatTop = 440
      FloatClientWidth = 94
      FloatClientHeight = 294
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarLargeButton17'
        end
        item
          Visible = True
          ItemName = 'btnDocFirma'
        end
        item
          Visible = True
          ItemName = 'btnDocProtocolla'
        end
        item
          Visible = True
          ItemName = 'btnDocConserva'
        end
        item
          Visible = True
          ItemName = 'btnDocInviaPec'
        end
        item
          Visible = True
          ItemName = 'btnDocInviaMail'
        end
        item
          Visible = True
          ItemName = 'btnDocAggiornaStato'
        end
        item
          Visible = True
          ItemName = 'btnDocVersioni'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarLargeButton1: TdxBarLargeButton
      Action = actPrint
      Category = 0
    end
    object dxBarLargeButton2: TdxBarLargeButton
      Action = actOpen
      Category = 0
    end
    object dxBarLargeButton3: TdxBarLargeButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarLargeButton4: TdxBarLargeButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarLargeButton5: TdxBarLargeButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarLargeButton6: TdxBarLargeButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarLargeButton7: TdxBarLargeButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton1: TdxBarButton
      Action = actOpen
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = actSave
      Category = 0
    end
    object dxBarLargeButton8: TdxBarLargeButton
      Action = actPdf
      Category = 0
    end
    object dxBarLargeButton9: TdxBarLargeButton
      Action = actEmail
      Category = 0
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'New SubItem'
      Category = 0
      Visible = ivAlways
      ItemLinks = <>
    end
    object dxBarButton3: TdxBarButton
      Action = actFind
      Category = 0
    end
    object dxBarButton4: TdxBarButton
      Action = actDesigner
      Category = 0
    end
    object dxBarLargeButton10: TdxBarLargeButton
      Action = actFirst
      Category = 0
    end
    object dxBarLargeButton11: TdxBarLargeButton
      Action = actPrior
      Category = 0
    end
    object dxBarLargeButton12: TdxBarLargeButton
      Action = actNext
      Category = 0
      ImageIndex = 161
    end
    object dxBarLargeButton13: TdxBarLargeButton
      Action = actLast
      Category = 0
    end
    object dxBarLargeButton14: TdxBarLargeButton
      Action = actZoomPlus
      Category = 0
    end
    object dxBarLargeButton15: TdxBarLargeButton
      Action = actZoomMinus
      Category = 0
    end
    object dxBarButton5: TdxBarButton
      Action = actZoomWholePage
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = actZoomPageWidth
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Action = actZoom100
      Category = 0
    end
    object dxBarButton8: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object dxBarButton9: TdxBarButton
      Action = actEmail
      Category = 0
      Visible = ivNever
    end
    object dxBarLargeButton16: TdxBarLargeButton
      Action = Chiudi
      Category = 0
    end
    object btnDocFirma: TdxBarLargeButton
      Action = actDocFirma
      Category = 0
    end
    object btnDocProtocolla: TdxBarLargeButton
      Action = actDocProtocolla
      Category = 0
    end
    object btnDocConserva: TdxBarLargeButton
      Action = actDocConserva
      Category = 0
    end
    object btnDocInviaPec: TdxBarLargeButton
      Action = actDocInviaPec
      Category = 0
    end
    object btnDocInviaMail: TdxBarLargeButton
      Action = actDocInviaMail
      Category = 0
    end
    object btnDocAggiornaStato: TdxBarLargeButton
      Action = actDocAggiornaStato
      Category = 0
    end
    object btnDocVersioni: TdxBarLargeButton
      Action = actDocVersioni
      Category = 0
    end
    object dxBarLargeButton17: TdxBarLargeButton
      Action = actDocGeneraAllegato
      Category = 0
    end
  end
end
