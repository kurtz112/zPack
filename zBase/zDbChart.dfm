object zDbChart: TzDbChart
  AlignWithMargins = True
  Left = 0
  Top = 0
  Width = 682
  Height = 385
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentColor = False
  ParentFont = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object Chart: TdxChartControl
    Left = 0
    Top = 29
    Width = 582
    Height = 356
    Align = alClient
    PopupMenu = popChart
  end
  object pnlDescrizione: TdxPanel
    Left = 582
    Top = 29
    Width = 100
    Height = 356
    Align = alRight
    Frame.Color = clBtnShadow
    Frame.Drag.Enabled = True
    TabOrder = 5
    Visible = False
  end
  object Titolo: TcxLabel
    Left = 24
    Top = 35
    Caption = 'Titolo'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Segoe UI'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 6
    Visible = False
  end
  object DataSource: TDataSource
    OnStateChange = DataSourceStateChange
    OnDataChange = DataSourceDataChange
    Left = 380
    Top = 92
  end
  object ChartSource: TDataSource
    Left = 380
    Top = 148
  end
  object ActionList: TActionList
    Images = dx.Immagini
    OnUpdate = ActionListUpdate
    Left = 376
    Top = 36
    object actDbRefresh: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Aggiorna'
      ShortCut = 116
      Hint = 'Rilegge i dati'
      ImageIndex = 45
      OnExecute = actDbRefreshExecute
    end
    object Elabora: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elabora'
      ImageIndex = 165
      OnExecute = ElaboraExecute
    end
    object actTipoBarre: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Barre'
      GroupIndex = 1
      ImageIndex = 376
      OnExecute = actTipoExecute
    end
    object actTipoBarreImpilate: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Barre impilate'
      GroupIndex = 1
      ImageIndex = 369
      OnExecute = actTipoExecute
    end
    object actTipoBarrePercentuali: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Barre in percentuale'
      GroupIndex = 1
      ImageIndex = 265
      OnExecute = actTipoExecute
    end
    object actTipoLinee: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Linee'
      GroupIndex = 1
      ImageIndex = 374
      OnExecute = actTipoExecute
    end
    object actTipoLineeImpilate: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Linee impilate'
      GroupIndex = 1
      ImageIndex = 371
      OnExecute = actTipoExecute
    end
    object actTipoAree: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Aree'
      GroupIndex = 1
      ImageIndex = 385
      OnExecute = actTipoExecute
    end
    object actTipoAreeImpilate: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Aree impilate'
      GroupIndex = 1
      ImageIndex = 375
      OnExecute = actTipoExecute
    end
    object actTipoTorta: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Torta'
      GroupIndex = 1
      ImageIndex = 364
      OnExecute = actTipoExecute
    end
    object actTipoCiambella: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Ciambella'
      GroupIndex = 1
      ImageIndex = 373
      OnExecute = actTipoExecute
    end
    object actTipoPredefinito: TzFocusedAction
      Category = 'Tipo'
      Caption = 'Tipo predefinito'
      Hint = 'Torna al tipo scelto nel dizionario'
      ImageIndex = 510
      OnExecute = actTipoPredefinitoExecute
    end
    object actLegenda: TzFocusedAction
      Category = 'Vista'
      Caption = 'Legenda'
      Hint = 'Mostra o nasconde la legenda'
      ImageIndex = 387
      OnExecute = actLegendaExecute
    end
    object actEtichette: TzFocusedAction
      Category = 'Vista'
      Caption = 'Etichette'
      Hint = 'Mostra o nasconde i valori sui punti'
      ImageIndex = 379
      OnExecute = actEtichetteExecute
    end
    object actRipristinaZoom: TzFocusedAction
      Category = 'Vista'
      Caption = 'Ripristina zoom'
      Hint = 'Torna alla scala iniziale'
      ImageIndex = 372
      OnExecute = actRipristinaZoomExecute
    end
    object Descrizione: TzFocusedAction
      Category = 'Other'
      Caption = 'Descrizione'
      AutoCheck = True
      ImageIndex = 232
      OnExecute = DescrizioneExecute
    end
    object RipristinaLayout: TzFocusedAction
      Category = 'Other'
      Caption = 'Ripristina layout'
      Hint = 'Torna a tipo, legenda ed etichette predefiniti'
      ImageIndex = 510
      OnExecute = RipristinaLayoutExecute
    end
    object actEsporta: TdxFileSaveAs
      Category = 'Export'
      Caption = 'Esporta'
      Dialog.DefaultExt = '*.png'
      Dialog.Filter = 'Immagine PNG|*.png|Immagine SVG|*.svg|PDF|*.pdf|Excel|*.xlsx|Word|*.docx|Metafile EMF|*.emf|Immagine JPEG|*.jpg'
      Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
      Hint = 'Salva il grafico come immagine o documento'
      ImageIndex = 221
      BeforeExecute = actEsportaBeforeExecute
      OnAccept = actEsportaAccept
    end
    object actCopiaImmagine: TzFocusedAction
      Category = 'Export'
      Caption = 'Copia immagine'
      Hint = 'Copia il grafico negli appunti'
      ImageIndex = 224
      OnExecute = actCopiaImmagineExecute
    end
    object actStampa: TzFocusedAction
      Category = 'Export'
      Caption = 'Stampa'
      ShortCut = 16464
      Hint = 'Anteprima di stampa'
      ImageIndex = 208
      OnExecute = actStampaExecute
    end
    object actPersonalizza: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza'
      ShortCut = 122
      Hint = 'Personalizza il grafico...'
      ImageIndex = 512
      OnExecute = actPersonalizzaExecute
    end
    object actResetSerie: TzFocusedAction
      Category = 'Design'
      Caption = 'Rigenera serie'
      Hint = 'Ricrea le serie dai campi numerici'
      ImageIndex = 213
      OnExecute = actResetSerieExecute
    end
    object SalvaImpostazioni: TzFocusedAction
      Category = 'Design'
      Caption = 'Salva Impostazioni'
      ImageIndex = 524
      OnExecute = SalvaImpostazioniExecute
    end
    object CaricaImpostazioni: TzFocusedAction
      Category = 'Design'
      Caption = 'Carica Impostazioni'
      ImageIndex = 521
      OnExecute = CaricaImpostazioniExecute
    end
    object actSQL: TzFocusedAction
      Category = 'Design'
      Caption = 'SQL'
      ImageIndex = 220
      OnExecute = actSQLExecute
    end
    object MostraQueryUtilizzata: TzFocusedAction
      Category = 'Design'
      Caption = 'Mostra Query Utilizzata'
      ImageIndex = 244
      OnExecute = MostraQueryUtilizzataExecute
    end
    object CopiaQueryUtilizzata: TzFocusedAction
      Category = 'Design'
      Caption = 'Copia Query Utilizzata'
      ImageIndex = 62
      OnExecute = CopiaQueryUtilizzataExecute
    end
    object CopyName: TzFocusedAction
      Category = 'Design'
      Caption = 'Copia ChartID'
      ImageIndex = 61
      OnExecute = CopyNameExecute
    end
    object NomeFileIni: TzFocusedAction
      Category = 'Design'
      Caption = 'Nome File Impostazioni'
      ImageIndex = -1
      OnExecute = NomeFileIniExecute
    end
    object EditTools: TzFocusedAction
      Category = 'Design'
      Caption = 'Tools...'
      ImageIndex = 512
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
    end
  end
  object dxBarManager: TdxBarManager
    AutoAlignBars = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    CanCustomize = False
    Categories.Strings = (
      'Default'
      'Design'
      'Other'
      'Dataset'
      'Export'
      'Tipo'
      'Vista')
    Categories.ItemsVisibles = (
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
      True)
    ImageOptions.Images = dx.Immagini
    ImageOptions.LargeImages = dx.Immagini
    ImageOptions.LargeIcons = True
    ImageOptions.UseLargeImagesForLargeIcons = True
    NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
    PopupMenuLinks = <
      item
        PopupMenu = popChart
      end>
    UseSystemFont = True
    OnShowToolbarsPopup = dxBarManagerShowToolbarsPopup
    Left = 297
    Top = 48
    PixelsPerInch = 96
    DockControlHeights = (
      0
      0
      29
      0)
    object dxBarToolbar: TdxBar
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
      FloatLeft = 816
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarControlContainerTitolo'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactDbRefresh'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonElabora'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarSubItemTipo'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactLegenda'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactEtichette'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactRipristinaZoom'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactEsporta'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactStampa'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object dxBarToolbarFree: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'ToolbarFree'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 260
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 816
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
    end
    object dxBarControlContainerTitolo: TdxBarControlContainerItem
      Caption = 'Titolo'
      Category = 0
      Hint = 'Titolo'
      Visible = ivAlways
      Control = Titolo
    end
    object dxBarEditTitolo: TcxBarEditItem
      Caption = 'Titolo'
      Category = 0
      Hint = 'Titolo del grafico'
      Visible = ivAlways
      OnChange = dxBarEditTitoloChange
      PropertiesClassName = 'TcxTextEditProperties'
      InternalEditValue = ''
    end
    object dxBarSubItemTipo: TdxBarSubItem
      Caption = 'Tipo'
      Category = 5
      Hint = 'Tipo di grafico'
      Visible = ivAlways
      ImageIndex = 4
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoBarre'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoBarreImpilate'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoBarrePercentuali'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoLinee'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoLineeImpilate'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoAree'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoAreeImpilate'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoTorta'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactTipoCiambella'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactTipoPredefinito'
        end>
    end
    object dxBarSubItemImpostazioni: TdxBarSubItem
      Caption = 'Impostazioni'
      Category = 0
      Visible = ivAlways
      ImageIndex = 512
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButtonNomeFileIni'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonEditTools'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonMostraQueryUtilizzata'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonCopiaQueryUtilizzata'
        end>
    end
    object dxBarButtonactDbRefresh: TdxBarButton
      Action = actDbRefresh
      Category = 3
    end
    object dxBarButtonElabora: TdxBarButton
      Action = Elabora
      Category = 3
    end
    object dxBarButtonactTipoBarre: TdxBarButton
      Action = actTipoBarre
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoBarreImpilate: TdxBarButton
      Action = actTipoBarreImpilate
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoBarrePercentuali: TdxBarButton
      Action = actTipoBarrePercentuali
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoLinee: TdxBarButton
      Action = actTipoLinee
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoLineeImpilate: TdxBarButton
      Action = actTipoLineeImpilate
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoAree: TdxBarButton
      Action = actTipoAree
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoAreeImpilate: TdxBarButton
      Action = actTipoAreeImpilate
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoTorta: TdxBarButton
      Action = actTipoTorta
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoCiambella: TdxBarButton
      Action = actTipoCiambella
      Category = 5
      ButtonStyle = bsChecked
    end
    object dxBarButtonactTipoPredefinito: TdxBarButton
      Action = actTipoPredefinito
      Category = 5
    end
    object dxBarButtonactLegenda: TdxBarButton
      Action = actLegenda
      Category = 6
      ButtonStyle = bsChecked
    end
    object dxBarButtonactEtichette: TdxBarButton
      Action = actEtichette
      Category = 6
      ButtonStyle = bsChecked
    end
    object dxBarButtonactRipristinaZoom: TdxBarButton
      Action = actRipristinaZoom
      Category = 6
    end
    object dxBarButtonDescrizione: TdxBarButton
      Action = Descrizione
      Category = 2
      ButtonStyle = bsChecked
    end
    object dxBarButtonRipristinaLayout: TdxBarButton
      Action = RipristinaLayout
      Category = 2
    end
    object dxBarButtonactEsporta: TdxBarButton
      Action = actEsporta
      Category = 4
    end
    object dxBarButtonactCopiaImmagine: TdxBarButton
      Action = actCopiaImmagine
      Category = 4
    end
    object dxBarButtonactStampa: TdxBarButton
      Action = actStampa
      Category = 4
    end
    object dxBarButtonactPersonalizza: TdxBarButton
      Action = actPersonalizza
      Category = 1
    end
    object dxBarButtonactResetSerie: TdxBarButton
      Action = actResetSerie
      Category = 1
    end
    object dxBarButtonSalvaImpostazioni: TdxBarButton
      Action = SalvaImpostazioni
      Category = 1
    end
    object dxBarButtonCaricaImpostazioni: TdxBarButton
      Action = CaricaImpostazioni
      Category = 1
    end
    object dxBarButtonactSQL: TdxBarButton
      Action = actSQL
      Category = 1
    end
    object dxBarButtonMostraQueryUtilizzata: TdxBarButton
      Action = MostraQueryUtilizzata
      Category = 1
    end
    object dxBarButtonCopiaQueryUtilizzata: TdxBarButton
      Action = CopiaQueryUtilizzata
      Category = 1
    end
    object dxBarButtonCopyName: TdxBarButton
      Action = CopyName
      Category = 1
    end
    object dxBarButtonNomeFileIni: TdxBarButton
      Action = NomeFileIni
      Category = 1
    end
    object dxBarButtonEditTools: TdxBarButton
      Action = EditTools
      Category = 1
    end
  end
  object popChart: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonElabora'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbRefresh'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarSubItemTipo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactLegenda'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactEtichette'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactRipristinaZoom'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonRipristinaLayout'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactEsporta'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactCopiaImmagine'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactStampa'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarEditTitolo'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonDescrizione'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarSubItemImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactResetSerie'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSalvaImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonCaricaImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonCopyName'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactSQL'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizza'
      end>
    UseOwnFont = False
    OnPopup = PopupChartPopup
    Left = 297
    Top = 98
    PixelsPerInch = 96
  end
end
