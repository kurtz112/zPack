object zDbTree: TzDbTree
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
  object Titolo: TcxLabel
    Left = 24
    Top = 35
    Caption = 'Titolo'
    ParentFont = False
    PopupMenu = popTree
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Segoe UI'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
    Visible = False
  end
  object cxDBTreeList: TcxDBTreeList
    AlignWithMargins = True
    Left = 3
    Top = 32
    Width = 576
    Height = 350
    Align = alClient
    Bands = <>
    DataController.DataSource = DataSource
    OptionsData.CancelOnExit = False
    OptionsData.Deleting = False
    OptionsData.SyncMode = False
    PopupMenu = popTree
    RootValue = -1
    ScrollbarAnnotations.CustomAnnotations = <>
    TabOrder = 1
  end
  object pnlDescrizione: TdxPanel
    Left = 582
    Top = 29
    Width = 100
    Height = 356
    Align = alRight
    Frame.Color = clBtnShadow
    Frame.Drag.Enabled = True
    TabOrder = 6
    Visible = False
  end
  object DataSource: TDataSource
    OnStateChange = DataSourceStateChange
    OnDataChange = DataSourceDataChange
    Left = 380
    Top = 92
  end
  object ActionList: TActionList
    Images = dx.Immagini
    OnUpdate = ActionListUpdate
    Left = 376
    Top = 36
    object actDbFirst: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Primo nodo'
      Hint = 'Primo nodo'
      ImageIndex = 146
      ShortCut = 16420
      OnExecute = actDbFirstExecute
    end
    object actDbPrior: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Nodo precedente'
      Hint = 'Nodo precedente'
      ImageIndex = 168
      ShortCut = 16417
      OnExecute = actDbPriorExecute
    end
    object actDbNext: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Nodo successivo'
      Hint = 'Nodo successivo'
      ImageIndex = 161
      ShortCut = 16418
      OnExecute = actDbNextExecute
    end
    object actDbLast: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Ultimo nodo'
      Hint = 'Ultimo nodo visibile'
      ImageIndex = 156
      ShortCut = 16419
      OnExecute = actDbLastExecute
    end
    object actVaiAlPadre: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Vai al padre'
      Hint = 'Porta il fuoco sul nodo padre'
      OnExecute = actVaiAlPadreExecute
    end
    object actDbRefresh: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Aggiorna'
      Hint = 'Aggiorna'
      ImageIndex = 45
      ShortCut = 116
      OnExecute = actDbRefreshExecute
    end
    object actDbInsert: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Inserisci'
      Hint = 'Inserisci un nodo allo stesso livello'
      ImageIndex = 38
      ShortCut = 118
      OnExecute = actDbInsertExecute
    end
    object actInserisciFiglio: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Inserisci figlio'
      Hint = 'Inserisci un nodo sotto quello selezionato'
      ImageIndex = 125
      ShortCut = 8310
      OnExecute = actInserisciFiglioExecute
    end
    object actInserisciRadice: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Inserisci radice'
      Hint = 'Inserisci un nodo di primo livello'
      ImageIndex = 38
      OnExecute = actInserisciRadiceExecute
    end
    object actDbEdit: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Modifica'
      Hint = 'Modifica il record'
      ImageIndex = 44
      ShortCut = 113
      OnExecute = actDbEditExecute
    end
    object actDbDelete: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elimina'
      Hint = 'Elimina il record'
      ImageIndex = 500
      ShortCut = 16430
      OnExecute = actDbDeleteExecute
    end
    object actDbPost: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Applica'
      Hint = 'Salva le modifiche'
      ImageIndex = 40
      ShortCut = 16397
      OnExecute = actDbPostExecute
    end
    object actDbCancel: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Annulla'
      Hint = 'Annulla le modifiche'
      ImageIndex = 43
      OnExecute = actDbCancelExecute
    end
    object actTrova: TzFocusedAction
      Category = 'Other'
      Caption = 'Trova'
      Hint = 'Cerca nei nodi (Ctrl+F)'
      ImageIndex = 189
      OnExecute = actTrovaExecute
    end
    object Espandi: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Espandi'
      Hint = 'Apre tutti i nodi'
      ImageIndex = 124
      OnExecute = EspandiExecute
    end
    object Riduci: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Riduci'
      Hint = 'Chiude tutti i nodi'
      ImageIndex = 126
      OnExecute = RiduciExecute
    end
    object actEspandiRamo: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Espandi ramo'
      Hint = 'Apre il nodo selezionato e tutti i suoi discendenti'
      ImageIndex = 124
      OnExecute = actEspandiRamoExecute
    end
    object actRiduciRamo: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Riduci ramo'
      Hint = 'Chiude il nodo selezionato e tutti i suoi discendenti'
      ImageIndex = 126
      OnExecute = actRiduciRamoExecute
    end
    object AdattaLarghezze: TzFocusedAction
      Category = 'Other'
      Caption = 'Adatta larghezze'
      Hint = 'Adatta la larghezza delle colonne al contenuto'
      ImageIndex = 438
      OnExecute = AdattaLarghezzeExecute
    end
    object Elabora: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elabora'
      ImageIndex = 165
      OnExecute = ElaboraExecute
    end
    object actExcel: TdxFileSaveAs
      Category = 'Export'
      Caption = 'Excel'
      Dialog.DefaultExt = '*.xlsx'
      Dialog.Filter = 'Excel|*.xlsx|Excel 97|*.xls|CSV|*.csv'
      Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
      Hint = 'esporta in excel'
      ImageIndex = 225
      BeforeExecute = actExcelBeforeExecute
      OnAccept = actExcelAccept
    end
    object actStampa: TzFocusedAction
      Category = 'Export'
      Caption = 'Stampa'
      Hint = 'Anteprima di stampa'
      ShortCut = 16464
      OnExecute = actStampaExecute
    end
    object Descrizione: TzFocusedAction
      Category = 'Other'
      AutoCheck = True
      Caption = 'Descrizione'
      ImageIndex = 4
      OnExecute = DescrizioneExecute
    end
    object RipristinaLayout: TzFocusedAction
      Category = 'Other'
      Caption = 'Ripristina layout'
      Hint = 'Torna al layout predefinito dell'#39'albero'
      ImageIndex = 510
      OnExecute = RipristinaLayoutExecute
    end
    object actPersonalizza: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza l'#39'albero...'
      ImageIndex = 512
      ShortCut = 122
      OnExecute = actPersonalizzaExecute
    end
    object actPersonalizzaColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Colonne...'
      Hint = 'Sposta e nascondi le colonne; poi Salva Impostazioni'
      ImageIndex = 217
      OnExecute = actPersonalizzaColonneExecute
    end
    object actPersonalizzaCampo: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza Campo'
      ImageIndex = 270
      ShortCut = 16506
      OnExecute = actPersonalizzaCampoExecute
    end
    object actResetColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Reset Colonne'
      ImageIndex = 543
      OnExecute = actResetColonneExecute
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
      ShortCut = 57432
      OnExecute = actSQLExecute
    end
    object MostraQueryUtilizzata: TzFocusedAction
      Category = 'Debug'
      Caption = 'Mostra Query Utilizzata'
      ImageIndex = 244
      OnExecute = MostraQueryUtilizzataExecute
    end
    object CopiaQueryUtilizzata: TzFocusedAction
      Category = 'Debug'
      Caption = 'Copia Query Utilizzata'
      ImageIndex = 62
      OnExecute = CopiaQueryUtilizzataExecute
    end
    object CopyName: TzFocusedAction
      Category = 'Design'
      Caption = 'Copia TreeID'
      ImageIndex = 61
      OnExecute = CopyNameExecute
    end
    object NomeFileIni: TzFocusedAction
      Category = 'Design'
      Caption = 'Nome File Layout'
      OnExecute = NomeFileIniExecute
    end
    object EditTools: TzFocusedAction
      Category = 'Design'
      Caption = 'Tools...'
      ImageIndex = 514
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
      'Export')
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
    ImageOptions.LargeImages = dx.Immagini
    ImageOptions.LargeIcons = True
    ImageOptions.UseLargeImagesForLargeIcons = True
    NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
    PopupMenuLinks = <
      item
        PopupMenu = popTree
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
          ItemName = 'dxBarButtonactDbFirst'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbPrior'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbNext'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbLast'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactVaiAlPadre'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbRefresh'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactDbInsert'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactInserisciFiglio'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbEdit'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbDelete'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbPost'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbCancel'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactTrova'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonEspandi'
        end
        item
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonRiduci'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonElabora'
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
      DockedLeft = 609
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
      Hint = 'Titolo'
      Visible = ivAlways
      OnChange = dxBarEditTitoloChange
      PropertiesClassName = 'TcxTextEditProperties'
      InternalEditValue = ''
    end
    object dxBarSubItemImpostazioni: TdxBarSubItem
      Caption = 'Impostazioni'
      Category = 0
      Visible = ivAlways
      ImageIndex = 512
      ItemLinks = <
        item
          Visible = True
          ItemName = 'dxBarButtonactResetColonne'
        end
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
    object dxBarButtonactPersonalizza: TdxBarButton
      Action = actPersonalizza
      Category = 1
    end
    object dxBarButtonactPersonalizzaColonne: TdxBarButton
      Action = actPersonalizzaColonne
      Category = 1
    end
    object dxBarButtonactPersonalizzaCampo: TdxBarButton
      Action = actPersonalizzaCampo
      Category = 1
    end
    object dxBarButtonactResetColonne: TdxBarButton
      Action = actResetColonne
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
    object dxBarButtonactTrova: TdxBarButton
      Action = actTrova
      Category = 2
    end
    object dxBarButtonAdattaLarghezze: TdxBarButton
      Action = AdattaLarghezze
      Category = 2
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
    object dxBarButtonactDbFirst: TdxBarButton
      Action = actDbFirst
      Category = 3
    end
    object dxBarButtonactDbPrior: TdxBarButton
      Action = actDbPrior
      Category = 3
    end
    object dxBarButtonactDbNext: TdxBarButton
      Action = actDbNext
      Category = 3
    end
    object dxBarButtonactDbLast: TdxBarButton
      Action = actDbLast
      Category = 3
    end
    object dxBarButtonactVaiAlPadre: TdxBarButton
      Action = actVaiAlPadre
      Category = 3
    end
    object dxBarButtonactDbRefresh: TdxBarButton
      Action = actDbRefresh
      Category = 3
    end
    object dxBarButtonactDbInsert: TdxBarButton
      Action = actDbInsert
      Category = 3
    end
    object dxBarButtonactInserisciFiglio: TdxBarButton
      Action = actInserisciFiglio
      Category = 3
    end
    object dxBarButtonactInserisciRadice: TdxBarButton
      Action = actInserisciRadice
      Category = 3
    end
    object dxBarButtonactDbEdit: TdxBarButton
      Action = actDbEdit
      Category = 3
    end
    object dxBarButtonactDbDelete: TdxBarButton
      Action = actDbDelete
      Category = 3
    end
    object dxBarButtonactDbPost: TdxBarButton
      Action = actDbPost
      Category = 3
    end
    object dxBarButtonactDbCancel: TdxBarButton
      Action = actDbCancel
      Category = 3
    end
    object dxBarButtonEspandi: TdxBarButton
      Action = Espandi
      Category = 3
    end
    object dxBarButtonRiduci: TdxBarButton
      Action = Riduci
      Category = 3
    end
    object dxBarButtonactEspandiRamo: TdxBarButton
      Action = actEspandiRamo
      Category = 3
    end
    object dxBarButtonactRiduciRamo: TdxBarButton
      Action = actRiduciRamo
      Category = 3
    end
    object dxBarButtonElabora: TdxBarButton
      Action = Elabora
      Category = 3
    end
    object dxBarButtonactExcel: TdxBarButton
      Action = actExcel
      Category = 4
    end
    object dxBarButtonactStampa: TdxBarButton
      Action = actStampa
      Category = 4
    end
  end
  object popTree: TdxBarPopupMenu
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
        Visible = True
        ItemName = 'dxBarButtonactExcel'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactStampa'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactTrova'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonEspandi'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonRiduci'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactEspandiRamo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactRiduciRamo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonAdattaLarghezze'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonRipristinaLayout'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactInserisciRadice'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactVaiAlPadre'
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
        ItemName = 'dxBarButtonactPersonalizzaColonne'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizzaCampo'
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
    OnPopup = PopupTreePopup
    Left = 297
    Top = 98
    PixelsPerInch = 96
  end
end
