object zDbView: TzDbView
  Left = 0
  Top = 0
  Width = 509
  Height = 329
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
  OnResize = FrameResize
  object Titolo: TcxLabel
    Left = 24
    Top = 35
    Caption = 'Titolo'
    ParentFont = False
    PopupMenu = popGrid
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Segoe UI'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
    Visible = False
  end
  object cxGrid: TcxGrid
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 409
    Height = 329
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    PopupMenu = popGrid
    TabOrder = 1
    object cxGridDBTableView: TcxGridDBTableView
      OnDblClick = cxGridDBTableViewDblClick
      OnMouseDown = cxGridDBTableViewMouseDown
      FilterBox.CustomizeButtonAlignment = fbaLeft
      FilterBox.Position = fpTop
      FindPanel.DisplayMode = fpdmManual
      FindPanel.FocusViewOnApplyFilter = True
      ScrollbarAnnotations.Active = True
      OnFilterControlDialogShow = cxGridDBTableViewFilterControlDialogShow
      OnFocusedItemChanged = cxGridDBTableViewFocusedItemChanged
      OnSelectionChanged = cxGridDBTableViewSelectionChanged
      DataController.DataModeController.GridMode = True
      DataController.DataSource = DataSource
      DataController.Filter.Options = [fcoCaseInsensitive, fcoShowOperatorDescription]
      DataController.Filter.Active = True
      DataController.Filter.DateTimeFormat = 'dd.mm.yyyy'
      DataController.Filter.IgnoreOrigin = False
      DataController.Summary.OnAfterSummary = cxGridDBTableViewDataControllerSummaryAfterSummary
      DataController.OnSortingChanged = cxGridDBTableViewDataControllerSortingChanged
      Filtering.ColumnMRUItemsList = False
      FilterRow.OperatorCustomization = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsBehavior.BestFitMaxRecordCount = 100
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsView.NoDataToDisplayInfoText = '<nessun dato da visualizzare>'
      OptionsView.GroupByHeaderLayout = ghlHorizontal
      OptionsView.GroupFooterMultiSummaries = True
      OptionsView.HeaderEndEllipsis = True
      OptionsView.Indicator = True
      OnColumnPosChanged = cxGridDBTableViewColumnPosChanged
      OnColumnSizeChanged = cxGridDBTableViewColumnSizeChanged
      object cxGridDBTableViewColumn1: TcxGridDBColumn
      end
    end
    object cxGridLevel: TcxGridLevel
      GridView = cxGridDBTableView
    end
  end
  object pnlDescrizione: TdxPanel
    Left = 409
    Top = 0
    Width = 100
    Height = 329
    Align = alRight
    Frame.Color = clBtnShadow
    Frame.Drag.Enabled = True
    LookAndFeel.SkinName = ''
    TabOrder = 2
    Visible = False
  end
  object DataSource: TDataSource
    OnStateChange = DataSourceStateChange
    OnDataChange = DataSourceDataChange
    Left = 252
    Top = 92
  end
  object ActionList: TActionList
    Images = dx.Immagini
    Left = 248
    Top = 36
    object EditTools: TzFocusedAction
      Category = 'Design'
      Caption = 'Tools...'
      ImageIndex = 514
      OnExecute = EditToolsExecute
      OnUpdate = EditToolsUpdate
    end
    object EditUndo: TEditUndo
      Category = 'Edit_Control'
      Caption = 'Annulla'
      Hint = 'annulla'
      ImageIndex = 54
      ShortCut = 16474
    end
    object EditCut: TEditCut
      Category = 'Edit_Control'
      Caption = 'Taglia'
      Hint = 'taglia'
      ImageIndex = 65
      ShortCut = 16472
    end
    object EditCopy: TEditCopy
      Category = 'Edit_Control'
      Caption = '&Copia'
      Hint = 'copia'
      ImageIndex = 64
      ShortCut = 16451
    end
    object EditPaste: TEditPaste
      Category = 'Edit_Control'
      Caption = '&Incolla'
      Hint = 'incolla'
      ImageIndex = 85
      ShortCut = 16470
    end
    object EditDelete: TEditDelete
      Category = 'Edit_Control'
      Caption = '&Elimina'
      Hint = 'elimina'
      ImageIndex = 66
      ShortCut = 8238
    end
    object EditSelectAll: TEditSelectAll
      Category = 'Edit_Control'
      Caption = 'Seleziona tutto'
      Hint = 'seleziona tutto'
      ImageIndex = 194
      ShortCut = 16449
    end
    object Incolonna: TzFocusedAction
      Category = 'Other'
      Caption = 'Incolonna'
      ImageIndex = 235
      OnExecute = IncolonnaExecute
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
    object CopiaColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Copia Colonne'
      ImageIndex = 292
      OnExecute = CopiaColonneExecute
    end
    object IncollaColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Incolla Colonne'
      ImageIndex = 85
      OnExecute = IncollaColonneExecute
    end
    object actResetColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Reset Colonne'
      OnExecute = actResetColonneExecute
      ImageIndex = 543
    end
    object actResetCaptionColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Reset Caption Colonne'
      OnExecute = actResetCaptionColonneExecute
    end
    object actSQL: TzFocusedAction
      Category = 'Design'
      Caption = 'SQL'
      ImageIndex = 220
      ShortCut = 57432
      OnExecute = actSQLExecute
    end
    object actDbFirst: TzFocusedAction
      Category = 'Dataset'
      Caption = 'All'#39'inizio'
      Hint = 'All'#39'inizio'
      ImageIndex = 146
      ShortCut = 16420
      OnExecute = actDbFirstExecute
    end
    object actDbPrior: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Precedente'
      Hint = 'Precedente'
      ImageIndex = 168
      ShortCut = 16417
      OnExecute = actDbPriorExecute
    end
    object actDbNext: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Successivo'
      Hint = 'Successivo'
      ImageIndex = 161
      ShortCut = 16418
      OnExecute = actDbNextExecute
    end
    object actDbLast: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Ultimo'
      Hint = 'Ultimo'
      ImageIndex = 156
      ShortCut = 16419
      OnExecute = actDbLastExecute
    end
    object actDbEdit: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Modifica'
      Hint = 'Modifica'
      ImageIndex = 44
      SecondaryShortCuts.Strings = (
        'Ctrl+Enter')
      ShortCut = 117
      OnExecute = actDbEditExecute
    end
    object actDbInsert: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Inserisci'
      Hint = 'Inserisci'
      ImageIndex = 38
      ShortCut = 118
      OnExecute = actDbInsertExecute
    end
    object actDbDelete: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elimina'
      Hint = 'Elimina'
      ImageIndex = 500
      SecondaryShortCuts.Strings = (
        'Ctrl+Del')
      ShortCut = 120
      OnExecute = actDbDeleteExecute
    end
    object actPersonalizza: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza'
      Hint = 'Personalizza griglia...'
      ImageIndex = 512
      ShortCut = 122
      OnExecute = actPersonalizzaExecute
    end
    object actDbRefresh: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Aggiorna'
      Hint = 'Aggiorna'
      ImageIndex = 45
      ShortCut = 116
      OnExecute = actDbRefreshExecute
    end
    object actDbPost: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Applica'
      Hint = 'Applica'
      ImageIndex = 40
      OnExecute = actDbPostExecute
    end
    object actDbCancel: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Annulla'
      Hint = 'Annulla'
      ImageIndex = 43
      OnExecute = actDbCancelExecute
    end
    object actDuplica: TzFocusedAction
      Category = 'Other'
      Caption = 'Duplica'
      Hint = 'duplica il record corrente'
      ImageIndex = 42
      ShortCut = 119
      OnExecute = actDuplicaExecute
    end
    object RecordCount: TzFocusedAction
      Category = 'Other'
      Caption = 'N'#176' Records'
      ImageIndex = 106
      OnExecute = RecordCountExecute
    end
    object actSelezionaTutto: TzFocusedAction
      Category = 'Other'
      Caption = 'Seleziona tutto'
      Hint = 'seleziona tutto'
      ImageIndex = 194
      ShortCut = 16449
      OnExecute = actSelezionaTuttoExecute
    end
    object actNessuno: TzFocusedAction
      Category = 'Other'
      Caption = 'Nessuno'
      Hint = 'Deseleziona'
      Visible = False
      OnExecute = actNessunoExecute
    end
    object actFiltriAvanzati: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Filtri Avanzati...'
      Hint = 'apri la finestra dei filtri avanzati'
      ImageIndex = 80
      ShortCut = 115
      OnExecute = actFiltriAvanzatiExecute
      OnUpdate = FiltriUpdate
    end
    object actEliminaFiltri: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Elimina Filtri'
      Hint = 'elimina filtri'
      ImageIndex = 57
      SecondaryShortCuts.Strings = (
        'Ctrl+BkSp')
      ShortCut = 16392
      OnExecute = actEliminaFiltriExecute
      OnUpdate = FiltriUpdate
    end
    object actFiltroPerValore: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Filtro per valore'
      Hint = 'filtra per campo/valore selezionati'
      ImageIndex = 188
      ShortCut = 114
      OnExecute = actFiltroPerValoreExecute
      OnUpdate = FiltriUpdate
    end
    object actStampa: TzFocusedAction
      Category = 'Export'
      Caption = 'Stampa'
      ImageIndex = 208
      OnExecute = actStampaExecute
    end
    object actVisualizzaFooter: TzFocusedAction
      Category = 'Other'
      AutoCheck = True
      Caption = 'Visualizza Totali'
      Hint = 'visualizza i totali'
      ImageIndex = 398
      OnExecute = actVisualizzaFooterExecute
      OnUpdate = actVisualizzaFooterUpdate
    end
    object Parametri: TzFocusedAction
      Category = 'Dataset'
      Caption = 'Elabora'
      ImageIndex = 165
      OnExecute = ParametriExecute
    end
    object actCubo: TzFocusedAction
      Category = 'Other'
      Caption = 'Analisi'
      ImageIndex = 388
      OnExecute = actCuboExecute
    end
    object actPersonalizzaColonna: TzFocusedAction
      Category = 'Design'
      Caption = 'Personalizza Colonna'
      ImageIndex = 270
      ShortCut = 16506
      OnExecute = actPersonalizzaColonnaExecute
      OnUpdate = actPersonalizzaColonnaUpdate
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
    object ShowCard: TzFocusedAction
      Category = 'Design'
      Caption = 'Show Card'
      ImageIndex = 513
      OnExecute = ShowCardExecute
    end
    object CopyName: TzFocusedAction
      Category = 'Design'
      Caption = 'Copia ViewID'
      ImageIndex = 61
      OnExecute = CopyNameExecute
    end
    object NascondiColonna: TzFocusedAction
      Category = 'Design'
      Caption = 'Nascondi colonna'
      ImageIndex = 542
      OnExecute = NascondiColonnaExecute
    end
    object SelezionaColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Colonne...'
      ImageIndex = 217
      OnExecute = SelezionaColonneExecute
    end
    object Excel: TzFocusedAction
      Category = 'Export'
      Caption = 'Excel'
      ImageIndex = 225
      OnExecute = ExcelExecute
    end
    object ClearIniSectionAllUsers: TzFocusedAction
      Category = 'Design'
      Caption = 'Clear Ini'
      ImageIndex = -1
      OnExecute = ClearIniSectionAllUsersExecute
    end
    object NomeFileIni: TzFocusedAction
      Category = 'Design'
      Caption = 'Nome File Ini'
      ImageIndex = -1
      OnExecute = NomeFileIniExecute
    end
    object CercaColonna: TzFocusedAction
      Category = 'Other'
      Caption = 'Cerca Colonna'
      ImageIndex = 541
      OnExecute = CercaColonnaExecute
    end
    object actCerca: TzFocusedAction
      Category = 'Filtri'
      Caption = 'Cerca'
      ImageIndex = 185
      ShortCut = 16454
      OnExecute = actCercaExecute
    end
    object CaricaFiltri: TdxFileOpen
      Category = 'Filtri'
      Caption = 'Carica Filtri'
      Dialog.DefaultExt = '*.flt'
      Dialog.Filter = 'Filtri|*.flt|*.*|*.*'
      ImageIndex = 33
      OnAccept = CaricaFiltriAccept
    end
    object SalvaFiltri: TdxFileSaveAs
      Category = 'Filtri'
      Caption = 'Salva Filtri'
      Dialog.DefaultExt = '*.flt'
      Dialog.Filter = 'Filtri|*.flt|*.*|*.*'
      ImageIndex = 292
      OnAccept = SalvaFiltriAccept
    end
    object SalvaDisposizioneColonne: TzFocusedAction
      Category = 'Design'
      Caption = 'Salva Disposizione Colonne'
      ImageIndex = 524
      OnExecute = SalvaDisposizioneColonneExecute
    end
    object Esporta: TzFocusedAction
      Category = 'Export'
      Caption = 'Esporta'
      ImageIndex = 221
      OnExecute = EsportaExecute
    end
    object Permessi: TzFocusedAction
      Category = 'Design'
      Caption = 'Permessi'
      ImageIndex = 81
      OnExecute = PermessiExecute
      OnUpdate = PermessiUpdate
    end
    object actPermessiAzione: TzFocusedAction
      Category = 'Design'
      Caption = 'Permessi'
      ImageIndex = 81
      OnExecute = actPermessiAzioneExecute
    end
    object actProprietaAzione: TzFocusedAction
      Category = 'Design'
      Caption = 'Propriet'#224
      ImageIndex = 512
      OnExecute = actProprietaAzioneExecute
    end
    object OverrideCampo: TzFocusedAction
      Category = 'Design'
      Caption = 'Override'
      ImageIndex = 417
      OnExecute = OverrideCampoExecute
      OnUpdate = OverrideCampoUpdate
    end
    object CopiaColonnePerDX: TzFocusedAction
      Category = 'Design'
      Caption = 'Copia Colonne Per DX'
      ImageIndex = 63
      OnExecute = CopiaColonnePerDXExecute
      OnUpdate = CopiaColonnePerDXUpdate
    end
    object FormattazioneCondizionale: TzFocusedAction
      Category = 'Other'
      Caption = 'Formattazione Condizionale'
      ImageIndex = 378
      OnExecute = FormattazioneCondizionaleExecute
    end
    object Descrizione: TzFocusedAction
      Category = 'Design'
      AutoCheck = True
      Caption = 'Descrizione'
      ImageIndex = 4
      OnExecute = DescrizioneExecute
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
      'File'
      'Design'
      'Other'
      'Dataset'
      'Filtri'
      'Export'
      'Edit'
      'Memo'
      'Image')
    Categories.ItemsVisibles = (
      2
      2
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
        PopupMenu = popGrid
      end>
    UseSystemFont = True
    OnBarVisibleChange = dxBarManagerBarVisibleChange
    OnShowToolbarsPopup = dxBarManagerShowToolbarsPopup
    Left = 121
    Top = 48
    PixelsPerInch = 96
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
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactDbEdit'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbInsert'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbDelete'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonactDbPost'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbCancel'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactDbRefresh'
        end
        item
          BeginGroup = True
          UserDefine = [udPaintStyle]
          UserPaintStyle = psCaptionGlyph
          Visible = True
          ItemName = 'dxBarButtonParametri'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonactCubo'
        end
        item
          Visible = True
          ItemName = 'dxBarControlContainerFiltri'
        end
        item
          Visible = True
          ItemName = 'dxBarControlContainerOrderBy'
        end>
      OneOnRow = False
      Row = 0
      UseOwnFont = False
      Visible = False
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
      DockedLeft = 479
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
      Visible = False
      WholeRow = False
    end
    object dxBarControlContainerTitolo: TdxBarControlContainerItem
      Caption = 'Titolo'
      Category = 0
      Hint = 'Titolo'
      Visible = ivAlways
      Control = Titolo
    end
    object dxBarControlContainerFiltri: TdxBarControlContainerItem
      Caption = 'Filtri'
      Category = 0
      Hint = 'Filtri'
      Visible = ivAlways
    end
    object dxBarControlContainerOrderBy: TdxBarControlContainerItem
      Caption = 'Ordinamento'
      Category = 0
      Hint = 'Ordinamento'
      Visible = ivAlways
    end
    object dxBarButton1: TdxBarButton
      Action = actPersonalizzaColonna
      Category = 0
    end
    object dxBarButton2: TdxBarButton
      Action = actResetColonne
      Category = 0
    end
    object dxBarButton3: TdxBarButton
      Action = CaricaImpostazioni
      Category = 0
    end
    object dxBarSubItemImpostazioni: TdxBarSubItem
      Caption = 'Impostazioni'
      Category = 0
      Visible = ivAlways
      ImageIndex = 512
      ItemLinks = <
        item
          ViewLayout = ivlGlyphControlCaption
          Visible = True
          ItemName = 'cxBarItemAutoWidth'
        end
        item
          ViewLayout = ivlGlyphControlCaption
          Visible = True
          ItemName = 'cxBarItemBorder'
        end
        item
          ViewLayout = ivlGlyphControlCaption
          Visible = True
          ItemName = 'cxBarItemMultiSelect'
        end
        item
          ViewLayout = ivlGlyphControlCaption
          Visible = True
          ItemName = 'cxBarItemFooter'
        end
        item
          ViewLayout = ivlGlyphControlCaption
          Visible = True
          ItemName = 'cxBarItemCube'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonCopiaSelected'
        end
        item
          Visible = True
          ItemName = 'dxBarButtonIncollaSelected'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButtonCopiaColonnePerDX'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton2'
        end
        item
          Visible = True
          ItemName = 'dxBarButton23'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton27'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton8'
        end
        item
          Visible = True
          ItemName = 'dxBarButton11'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'dxBarButton5'
        end
        item
          Visible = True
          ItemName = 'dxBarButton6'
        end>
    end
    object dxBarButton5: TdxBarButton
      Action = MostraQueryUtilizzata
      Category = 0
    end
    object dxBarButton6: TdxBarButton
      Action = CopiaQueryUtilizzata
      Category = 0
    end
    object dxBarButton7: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
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
    object dxBarButton9: TdxBarButton
      Action = ShowCard
      Category = 0
    end
    object dxBarButton10: TdxBarButton
      Action = CopyName
      Category = 0
    end
    object cxBarItemModifyFlags: TcxBarEditItem
      Category = 0
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckGroupProperties'
      Properties.Columns = 3
      Properties.EditValueFormat = cvfStatesString
      Properties.Items = <
        item
          Caption = 'Ins'
        end
        item
          Caption = 'Upd'
        end
        item
          Caption = 'Del'
        end>
      Properties.OnChange = cxBarItemModifyFlagsPropertiesChange
    end
    object cxBarItemReadOnly: TcxBarEditItem
      Category = 0
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckGroupProperties'
      Properties.EditValueFormat = cvfStatesString
      Properties.Items = <
        item
          Caption = 'Sola Lettura'
        end>
      Properties.OnChange = cxBarItemReadOnlyPropertiesChange
    end
    object cxBarItemAutoWidth: TcxBarEditItem
      Caption = 'AutoWidth'
      Category = 0
      Hint = 'AutoWidth'
      Visible = ivAlways
      ShowCaption = True
      Width = 0
      PropertiesClassName = 'TcxCheckBoxProperties'
      Properties.Alignment = taRightJustify
      Properties.ImmediatePost = True
      Properties.ReadOnly = False
      Properties.UseAlignmentWhenInplace = True
      Properties.OnChange = cxBarItemAutoWidthPropertiesChange
    end
    object cxBarItemBorder: TcxBarEditItem
      Caption = 'Border (eliminato)'
      Category = 0
      Enabled = False
      Hint = 'Border (eliminato)'
      Visible = ivAlways
      ShowCaption = True
      Width = 0
      PropertiesClassName = 'TcxCheckBoxProperties'
      Properties.Alignment = taRightJustify
      Properties.ImmediatePost = True
      Properties.ReadOnly = False
      Properties.UseAlignmentWhenInplace = True
      Properties.OnChange = cxBarItemBorderPropertiesChange
    end
    object cxBarItemMultiSelect: TcxBarEditItem
      Caption = 'MultiSelect'
      Category = 0
      Hint = 'MultiSelect'
      Visible = ivAlways
      ShowCaption = True
      Width = 0
      PropertiesClassName = 'TcxCheckBoxProperties'
      Properties.Alignment = taRightJustify
      Properties.ImmediatePost = True
      Properties.ReadOnly = False
      Properties.UseAlignmentWhenInplace = True
      Properties.OnChange = cxBarItemMultiSelectPropertiesChange
    end
    object cxBarItemFooter: TcxBarEditItem
      Caption = 'Footer'
      Category = 0
      Hint = 'Footer'
      Visible = ivAlways
      ShowCaption = True
      Width = 0
      PropertiesClassName = 'TcxCheckBoxProperties'
      Properties.Alignment = taRightJustify
      Properties.ImmediatePost = True
      Properties.ReadOnly = False
      Properties.UseAlignmentWhenInplace = True
      Properties.OnChange = cxBarItemFooterPropertiesChange
    end
    object cxBarItemCube: TcxBarEditItem
      Caption = 'Cube'
      Category = 0
      Hint = 'Cube'
      Visible = ivAlways
      ShowCaption = True
      Width = 0
      PropertiesClassName = 'TcxCheckBoxProperties'
      Properties.Alignment = taRightJustify
      Properties.ImmediatePost = True
      Properties.ReadOnly = False
      Properties.UseAlignmentWhenInplace = True
      Properties.OnChange = cxBarItemCubePropertiesChange
    end
    object dxBarButton4: TdxBarButton
      Action = actCerca
      Category = 0
    end
    object dxBarItemCardInherits: TcxBarEditItem
      Category = 0
      Hint = 'Card Inherits'
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckGroupProperties'
      Properties.EditValueFormat = cvfStatesString
      Properties.Items = <
        item
          Caption = 'Propaga alla card'
        end>
      Properties.OnChange = cxBarEditItemCardInheritsPropertiesChange
    end
    object dxBarButton8: TdxBarButton
      Action = ClearIniSectionAllUsers
      Category = 0
    end
    object dxBarButton11: TdxBarButton
      Action = NomeFileIni
      Category = 0
    end
    object dxBarButton12: TdxBarButton
      Action = CercaColonna
      Category = 0
    end
    object dxBarButton13: TdxBarButton
      Action = SalvaFiltri
      Category = 0
    end
    object dxBarButton14: TdxBarButton
      Action = CaricaFiltri
      Category = 0
    end
    object dxBarButton15: TdxBarButton
      Action = SalvaDisposizioneColonne
      Category = 0
    end
    object dxBarButton18: TdxBarButton
      Action = Permessi
      Category = 0
    end
    object dxBarButton19: TdxBarButton
      Action = actPermessiAzione
      Category = 0
    end
    object dxBarButton20: TdxBarButton
      Action = actProprietaAzione
      Category = 0
    end
    object dxBarButton21: TdxBarButton
      Action = OverrideCampo
      Category = 0
    end
    object dxBarButton22: TdxBarButton
      Action = OverrideCampo
      Category = 0
    end
    object dxBarButton23: TdxBarButton
      Action = actResetCaptionColonne
      Category = 0
    end
    object dxBarButtonCopiaColonnePerDX: TdxBarButton
      Action = CopiaColonnePerDX
      Category = 0
    end
    object dxBarButton24: TdxBarButton
      Action = actVisualizzaFooter
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton25: TdxBarButton
      Action = FormattazioneCondizionale
      Category = 0
    end
    object dxBarButton26: TdxBarButton
      Action = Descrizione
      Category = 0
      ButtonStyle = bsChecked
    end
    object dxBarButton27: TdxBarButton
      Action = EditTools
      Category = 0
    end
    object dxBarButtonSalvaImpostazioni: TdxBarButton
      Action = SalvaImpostazioni
      Category = 2
    end
    object dxBarButtonCaricaImpostazioni: TdxBarButton
      Action = CaricaImpostazioni
      Category = 2
    end
    object dxBarButtonIncollaSelected: TdxBarButton
      Action = IncollaColonne
      Category = 2
    end
    object dxBarButtonCopiaSelected: TdxBarButton
      Action = CopiaColonne
      Category = 2
    end
    object dxBarButtonNascondiColonna: TdxBarButton
      Action = NascondiColonna
      Category = 2
    end
    object dxBarButtonSelezionaColonne: TdxBarButton
      Action = SelezionaColonne
      Category = 2
    end
    object dxBarButtonactSQL: TdxBarButton
      Action = actSQL
      Category = 2
    end
    object dxBarButtonactPersonalizza: TdxBarButton
      Action = actPersonalizza
      Category = 2
    end
    object dxBarButtonIncolonna: TdxBarButton
      Action = Incolonna
      Category = 3
    end
    object dxBarButtonRecordCount: TdxBarButton
      Action = RecordCount
      Category = 3
    end
    object dxBarButtonactSelezionaTutto: TdxBarButton
      Action = actSelezionaTutto
      Category = 3
    end
    object dxBarButtonactNessuno: TdxBarButton
      Action = actNessuno
      Category = 3
    end
    object dxBarButtonactCubo: TdxBarButton
      Action = actCubo
      Category = 3
    end
    object dxBarButtonactDbFirst: TdxBarButton
      Action = actDbFirst
      Category = 4
    end
    object dxBarButtonactDbPrior: TdxBarButton
      Action = actDbPrior
      Category = 4
    end
    object dxBarButtonactDbNext: TdxBarButton
      Action = actDbNext
      Category = 4
    end
    object dxBarButtonactDbLast: TdxBarButton
      Action = actDbLast
      Category = 4
    end
    object dxBarButtonactDbEdit: TdxBarButton
      Action = actDbEdit
      Category = 4
    end
    object dxBarButtonactDbInsert: TdxBarButton
      Action = actDbInsert
      Category = 4
    end
    object dxBarButtonactDbDelete: TdxBarButton
      Action = actDbDelete
      Category = 4
    end
    object dxBarButtonactDbRefresh: TdxBarButton
      Action = actDbRefresh
      Category = 4
    end
    object dxBarButtonactDbPost: TdxBarButton
      Action = actDbPost
      Category = 4
    end
    object dxBarButtonactDbCancel: TdxBarButton
      Action = actDbCancel
      Category = 4
    end
    object dxBarButtonParametri: TdxBarButton
      Action = Parametri
      Category = 4
    end
    object dxBarButtonactDuplica: TdxBarButton
      Action = actDuplica
      Category = 4
    end
    object dxBarButtonactFiltriAvanzati: TdxBarButton
      Action = actFiltriAvanzati
      Category = 5
    end
    object dxBarButtonactEliminaFiltri: TdxBarButton
      Action = actEliminaFiltri
      Category = 5
    end
    object dxBarButtonactFiltroPerValore: TdxBarButton
      Action = actFiltroPerValore
      Category = 5
    end
    object SubmenuFiltriCategoria: TdxBarSubItem
      Caption = 'Filtri'
      Category = 5
      Visible = ivAlways
      ItemLinks = <>
    end
    object dxBarButtonactStampa: TdxBarButton
      Action = actStampa
      Category = 6
    end
    object dxBarButton17: TdxBarButton
      Action = Esporta
      Category = 6
    end
    object dxBarButton16: TdxBarButton
      Action = Excel
      Category = 6
    end
    object dxBarButtonEditUndo: TdxBarButton
      Action = EditUndo
      Category = 7
    end
    object dxBarButtonEditCut: TdxBarButton
      Action = EditCut
      Category = 7
    end
    object dxBarButtonEditCopy: TdxBarButton
      Action = EditCopy
      Category = 7
    end
    object dxBarButtonEditPaste: TdxBarButton
      Action = EditPaste
      Category = 7
    end
    object dxBarButtonEditDelete: TdxBarButton
      Action = EditDelete
      Category = 7
    end
    object dxBarButtonEditSelectAll: TdxBarButton
      Action = EditSelectAll
      Category = 7
    end
  end
  object popGrid: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonParametri'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbEdit'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbInsert'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDuplica'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbDelete'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactDbRefresh'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactSelezionaTutto'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonRecordCount'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton24'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton4'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactFiltroPerValore'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactFiltriAvanzati'
      end
      item
        Visible = True
        ItemName = 'SubmenuFiltriCategoria'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactEliminaFiltri'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton25'
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
        ItemName = 'dxBarButtonactStampa'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactCubo'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonIncolonna'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton12'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonNascondiColonna'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton26'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton22'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSelezionaColonne'
      end
      item
        Visible = True
        ItemName = 'dxBarButton15'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarEditTitolo'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'cxBarItemReadOnly'
      end
      item
        Visible = True
        ItemName = 'cxBarItemModifyFlags'
      end
      item
        Visible = True
        ItemName = 'dxBarItemCardInherits'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarSubItemImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonSalvaImpostazioni'
      end
      item
        Visible = True
        ItemName = 'dxBarButton3'
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
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactSQL'
      end
      item
        Visible = True
        ItemName = 'dxBarButton18'
      end
      item
        Visible = True
        ItemName = 'dxBarButton1'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonactPersonalizza'
      end>
    UseOwnFont = False
    OnPopup = PopupGridPopup
    Left = 121
    Top = 98
    PixelsPerInch = 96
  end
  object popColumn: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButtonEditUndo'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditCut'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditCopy'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditPaste'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditDelete'
      end
      item
        Visible = True
        ItemName = 'dxBarButtonEditSelectAll'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton21'
      end>
    UseOwnFont = False
    Left = 121
    Top = 149
    PixelsPerInch = 96
  end
  object zDbCardDlg: TzDbCardDlg
    Left = 255
    Top = 144
  end
  object cxGridPopupMenu: TcxGridPopupMenu
    Grid = cxGrid
    PopupMenus = <
      item
        GridView = cxGridDBTableView
        HitTypes = [gvhtGridNone, gvhtNone, gvhtCell, gvhtRecord, gvhtIndicator]
        Index = 0
        PopupMenu = popGrid
      end>
    OnPopup = cxGridPopupMenuPopup
    Left = 120
    Top = 208
  end
  object popFilter: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton14'
      end
      item
        Visible = True
        ItemName = 'dxBarButton13'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactFiltriAvanzati'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButtonactEliminaFiltri'
      end>
    UseOwnFont = False
    OnPopup = PopupGridPopup
    Left = 121
    Top = 266
    PixelsPerInch = 96
  end
  object popActions: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Visible = True
        ItemName = 'dxBarButton19'
      end
      item
        BeginGroup = True
        Visible = True
        ItemName = 'dxBarButton20'
      end>
    UseOwnFont = False
    OnPopup = popActionsPopup
    Left = 252
    Top = 264
    PixelsPerInch = 96
  end
end
